import time
import os

from .document_loader import convert_gdoc_to_pdf, extract_text_from_pdf, run_ocr_on_pdf, fetch_notion_content
from .embedding import chunk_text, embed_chunks
from .vectorstore import LocalFaissStore

"""
Hour 4 + Hour 8: update_pipeline & scheduling + 예외처리
 - update_documents_if_needed(): ingestion 중간에 에러 발생 시 건너뛰거나 로그만 찍고 계속
"""

DOCUMENTS = [
    {
        "title": "휴가양식",
        "type": "google_doc",
        "url": "https://docs.google.com/document/d/EXAMPLE-ID"
    },
    {
        "title": "시간표",
        "type": "google_sheet",
        "url": "https://docs.google.com/spreadsheets/d/EXAMPLE-ID"
    },
    {
        "title": "출석가이드",
        "type": "notion",
        "url": "https://notion.so/EXAMPLE"
    }
]

def load_last_update_time():
    filename = ".last_update_time"
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            val = f.read().strip()
            try:
                return float(val)
            except:
                return 0.0
    return 0.0

def save_last_update_time(timestamp: float):
    filename = ".last_update_time"
    with open(filename, 'w') as f:
        f.write(str(timestamp))

def update_documents_if_needed(store=None):
    interval_hours = float(os.getenv("UPDATE_INTERVAL_HOURS", "24"))
    last_update = load_last_update_time()
    now = time.time()
    elapsed = now - last_update
    need_update = (elapsed >= interval_hours * 3600)

    if not need_update:
        return store, False

    # 업데이트 수행
    all_contents = ingest_all_documents()

    if store is None:
        store = LocalFaissStore(dimension=768)

    all_embeddings = []
    all_metadatas = []

    for doc in all_contents:
        text = doc.get("text", None)
        if not text:
            # 문서 로딩 실패 or 빈 텍스트인 경우
            print(f"[Warning] Skipping doc: {doc.get('title')} (No text)")
            continue

        doc_title = doc.get("title", "Untitled")
        doc_url = doc.get("url", "")

        try:
            chunks = chunk_text(text, chunk_size=512, overlap=0)
            embeddings = embed_chunks(chunks,
                                      api_key=os.getenv("OPENAI_API_KEY", "DUMMY"),
                                      model=os.getenv("EMBEDDING_MODEL", "text-embedding-ada-002"))
        except Exception as e:
            print(f"[Error] chunk/embed failed on doc={doc_title}, {e}")
            continue

        for i, emb in enumerate(embeddings):
            meta = {
                "title": doc_title,
                "url": doc_url,
                "chunk_index": i,
                "text_snippet": chunks[i][:50]
            }
            all_embeddings.append(emb)
            all_metadatas.append(meta)

    store.add_documents(all_embeddings, all_metadatas)
    print(f"[update_pipeline] Updated FAISS store with {len(all_embeddings)} new embeddings.")

    save_last_update_time(now)
    print(f"[update_pipeline] Last update time set to {now}.")

    return store, True

def ingest_all_documents():
    all_contents = []
    for doc in DOCUMENTS:
        doc_type = doc.get("type")
        doc_url = doc.get("url")
        doc_title = doc.get("title")

        if "google" in doc_type:
            pdf_path = convert_gdoc_to_pdf(doc_url)
            if pdf_path is None:
                # 변환 실패
                print(f"[Warning] convert_gdoc_to_pdf failed for {doc_title}")
                continue

            extracted = extract_text_from_pdf(pdf_path)
            if extracted is None:
                print(f"[Warning] extract_text_from_pdf failed for {doc_title}")
                continue

            # (OCR optional)
            # ocr_result = run_ocr_on_pdf(pdf_path)

            all_contents.append({
                "title": doc_title,
                "type": doc_type,
                "url": doc_url,
                "text": extracted
            })

        elif doc_type == "notion":
            text_content, image_links = fetch_notion_content(doc_url)
            if text_content is None:
                print(f"[Warning] fetch_notion_content failed for {doc_title}")
                continue
            all_contents.append({
                "title": doc_title,
                "type": doc_type,
                "url": doc_url,
                "text": text_content,
                "images": image_links
            })
        else:
            print(f"[Warning] Unknown doc type: {doc_type}")
            continue

    return all_contents
