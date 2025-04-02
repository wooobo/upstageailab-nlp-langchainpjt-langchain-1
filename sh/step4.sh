#!/usr/bin/env bash
#
# step4.sh: Hour 4 - 업데이트 파이프라인 & 스케줄러 구현
# - update_pipeline.py: update_documents_if_needed + last_update_time 관리
# - main.py: 실행 시 자동 업데이트 시점 체크 후 갱신

echo "=== Start: Updating pipeline & scheduler (Hour 4) ==="

#############################################
# 1. update_pipeline.py 수정/덮어쓰기
#############################################
echo "Updating update_pipeline.py..."
cat <<'PYTHON' > project/modules/update_pipeline.py
import time
import os

from .document_loader import convert_gdoc_to_pdf, extract_text_from_pdf, run_ocr_on_pdf, fetch_notion_content
from .embedding import chunk_text, embed_chunks
from .vectorstore import LocalFaissStore

"""
Hour 4: update_pipeline & scheduling
 - 1) last_update_time 로드/저장
 - 2) update_documents_if_needed() -> 일정시간 경과 시 자동 업데이트
 - 3) 업데이트 시, 문서 ingest + chunk + embed + FAISS store 갱신
"""

# 기존 문서 목록 예시
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
    """
    로컬 파일에서 마지막 업데이트 시간(유닉스 타임스탬프)을 로드.
    파일이 없으면 0 반환.
    """
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
    """
    로컬 파일에 마지막 업데이트 시간(유닉스 타임스탬프) 저장
    """
    filename = ".last_update_time"
    with open(filename, 'w') as f:
        f.write(str(timestamp))

def update_documents_if_needed(store=None):
    """
    - 현재 시각과 .env의 UPDATE_INTERVAL_HOURS를 비교하여,
      시간이 지났으면 인제스트+임베딩+FAISS 갱신
    - 갱신 후 last_update_time 갱신
    - :param store: (Optional) 이미 생성된 LocalFaissStore 인스턴스.
                    없으면 새로 생성해서 반환.
    - :return: (store, updated:boolean)
    """
    interval_hours = float(os.getenv("UPDATE_INTERVAL_HOURS", "24"))
    last_update = load_last_update_time()
    now = time.time()

    elapsed = now - last_update
    need_update = (elapsed >= interval_hours * 3600)

    if not need_update:
        # 업데이트 불필요
        return store, False

    # 업데이트 수행
    # 1) 문서 ingestion
    all_contents = ingest_all_documents()
    # 2) chunk+embed -> store에 저장
    if store is None:
        store = LocalFaissStore(dimension=768)  # 차원 768로 가정

    # 전체 문서 chunk+embed
    all_embeddings = []
    all_metadatas = []
    for doc in all_contents:
        text = doc.get("text", "")
        doc_title = doc.get("title", "Untitled")
        doc_url = doc.get("url", "")

        chunks = chunk_text(text, chunk_size=512, overlap=0)
        embeddings = embed_chunks(chunks,
                                  api_key=os.getenv("OPENAI_API_KEY", "DUMMY"),
                                  model=os.getenv("EMBEDDING_MODEL", "text-embedding-ada-002"))

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

    # 마지막 업데이트 시간 갱신
    save_last_update_time(now)
    print(f"[update_pipeline] Last update time set to {now}.")

    return store, True

def ingest_all_documents():
    """
    (Hour 2 + Hour 3에서 사용하던 함수)
    문서를 순회하며 텍스트(및 이미지 링크)를 수집
    """
    all_contents = []
    for doc in DOCUMENTS:
        doc_type = doc.get("type")
        doc_url = doc.get("url")
        doc_title = doc.get("title")

        if "google" in doc_type:
            pdf_path = convert_gdoc_to_pdf(doc_url)
            extracted = extract_text_from_pdf(pdf_path)
            all_contents.append({
                "title": doc_title,
                "type": doc_type,
                "url": doc_url,
                "text": extracted
            })

        elif doc_type == "notion":
            text_content, image_links = fetch_notion_content(doc_url)
            all_contents.append({
                "title": doc_title,
                "type": doc_type,
                "url": doc_url,
                "text": text_content,
                "images": image_links
            })
        else:
            pass

    return all_contents
PYTHON

#############################################
# 2. main.py 수정: 실행 시 스케줄러 확인
#############################################
echo "Updating main.py..."
cat <<'PYTHON' > project/main.py
#!/usr/bin/env python3

import os
from dotenv import load_dotenv

from modules.vectorstore import LocalFaissStore
from modules.update_pipeline import update_documents_if_needed

def main():
    load_dotenv(dotenv_path='config.env')

    # 1) 스토어 생성 (처음에는 빈 상태)
    store = LocalFaissStore(dimension=768)

    # 2) update_documents_if_needed -> .env의 UPDATE_INTERVAL_HOURS 지난 경우 업데이트
    store, updated = update_documents_if_needed(store=store)

    if updated:
        print("[Main] Documents were updated. Now FAISS store is fresh.")
    else:
        print("[Main] No update needed. FAISS store is unchanged.")

    # 이후 RAG 질의응답 로직을 연결하거나,
    # 테스트 검색을 시도하는 코드를 작성 가능.

    # 예: 간단히 검색 테스트 (원하는 경우 주석 해제)
    # query = "휴가 신청 방법"
    # from modules.embedding import embed_chunks
    # query_emb = embed_chunks([query])[0]
    # results = store.search(query_emb, top_k=3)
    # print("[Search Results]")
    # for dist, meta in results:
    #     print(f" - dist={dist:.3f}, title={meta.get('title')}, snippet={meta.get('text_snippet')}")

if __name__ == "__main__":
    main()
PYTHON

echo "=== Done! ==="
echo "Now you can run:"
echo "  cd project"
echo "  source ../.venv/bin/activate"
echo "  python main.py"
echo "If '.last_update_time' doesn't exist or interval has passed, ingestion+embedding will run. Otherwise, it will skip."
