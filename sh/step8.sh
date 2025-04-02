#!/usr/bin/env bash
#
# step8.sh: Hour 8 - 예외처리 및 코드 정리
# - Updates document_loader.py, rag.py, update_pipeline.py, etc. with basic exception handling & code clean-up.

echo "=== Start: Hour 8 - Exception Handling & Code Clean-up ==="

#############################################
# 1. document_loader.py (예외처리 & 정리)
#############################################
echo "Updating document_loader.py..."
cat <<'PYTHON' > project/modules/document_loader.py
import os
import requests
import tempfile

"""
 Hour 2 + Hour 8: 문서 ingestion 설계 + 예외처리
 - Google Docs -> PDF 변환 (convert_gdoc_to_pdf)
 - PDF -> 텍스트 추출 (extract_text_from_pdf)
 - Upstage OCR API 스텁 (run_ocr_on_pdf)
 - 노션 문서 내용/이미지 링크 추출 (fetch_notion_content)
 + 예외처리 (파일없음, API 호출 실패 등)
"""

def convert_gdoc_to_pdf(doc_url: str) -> str:
    """
    [STUB] Google Docs/Slides/Sheets를 PDF로 변환하는 함수.
    실제로는 Google Drive API or Export Link를 써야 하지만
    MVP에서는 스텁으로 처리.
    예외처리:
      - 변환 실패 시 None 반환
    :param doc_url: 구글 문서 URL
    :return: 변환된 PDF 파일 경로 (로컬) or None
    """
    # (예시) docs/sample.pdf 존재하는지 체크
    pdf_path = "docs/sample.pdf"
    if not os.path.exists(pdf_path):
        print(f"[Error] PDF file not found: {pdf_path}")
        return None

    return pdf_path

def extract_text_from_pdf(pdf_path: str) -> str:
    """
    [STUB] PDF 파일에서 텍스트를 추출하는 함수.
    PyPDF2, pdfplumber, etc. 라이브러리를 활용 가능.
    예외처리:
      - 파일 없거나, 라이브러리 에러 발생 시 None 반환
    :param pdf_path: 로컬 PDF 경로
    :return: 추출된 텍스트 or None
    """
    if pdf_path is None or not os.path.exists(pdf_path):
        return None

    try:
        extracted_text = "PDF 내용 (예시)"
        # 실제 구현 시 pdfplumber / PyPDF2 + 전처리를 적용
        return extracted_text
    except Exception as e:
        print(f"[Error] Failed to extract text from PDF: {pdf_path}, {e}")
        return None

def run_ocr_on_pdf(pdf_path: str) -> str:
    """
    [STUB] Upstage OCR API 호출 스텁
    만약 PDF 내 표/이미지 등 별도 OCR이 필요하다면 이 함수를 사용.
    예외처리:
      - Network 실패, API 에러 시 None
    :param pdf_path: 로컬 PDF 경로
    :return: OCR 결과 텍스트 or None
    """
    if pdf_path is None or not os.path.exists(pdf_path):
        return None

    try:
        # actual code like:
        # with open(pdf_path, 'rb') as f:
        #     files = {'file': f}
        #     response = requests.post("UPSTAGE_OCR_ENDPOINT", files=files)
        #     response.raise_for_status()
        #     return response.text
        return "OCR 결과 텍스트 (예시)"
    except Exception as e:
        print(f"[Error] OCR call failed: {pdf_path}, {e}")
        return None

def fetch_notion_content(notion_url: str) -> (str, list):
    """
    [STUB] 노션 문서 내용과 이미지 링크 추출 함수.
    실제로는 Notion API 혹은 Public Access된 HTML 파싱 등을 해야 함.
    예외처리:
      - API 실패, 권한 문제 발생 시 None 반환 가능
    :param notion_url: 노션 페이지 URL
    :return: (노션 문서 전체 텍스트, [이미지 링크 목록]) or (None, [])
    """
    try:
        # 여기서는 간단히 스텁
        text_content = "노션 문서 내용 (예시)"
        image_links = [
            "https://notion.so/image1.png",
            "https://notion.so/image2.png"
        ]
        return text_content, image_links
    except Exception as e:
        print(f"[Error] Failed to fetch notion content: {notion_url}, {e}")
        return None, []

PYTHON

#############################################
# 2. rag.py (GPT API 예외처리)
#############################################
echo "Updating rag.py..."
cat <<'PYTHON' > project/modules/rag.py
import os
import requests
import json

from .embedding import embed_chunks

"""
Hour 5 + Hour 8: RAG + GPT 호출 + 예외처리
 - call_gpt(context, api_key, model, temperature, max_tokens): GPT API + 에러 핸들링
 - answer_query(query, store, history): RAG 파이프라인
"""

def call_gpt(context, api_key, model="gpt-4", temperature=0.7, max_tokens=1000):
    """
    실제 GPT-4 또는 사내 GPT 호환 API 호출 예시
    예외처리:
      - HTTP 에러, Timeout 등 발생 시 에러 메시지 반환
    """
    # Stub 모드면 그냥 샘플 메시지
    if api_key == "DUMMY_KEY":
        return f"[GPT_ANSWER_STUB] based on context: {context[:60]}..."

    endpoint = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    data = {
        "model": model,
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": context}
        ],
        "temperature": temperature,
        "max_tokens": max_tokens,
    }
    try:
        response = requests.post(endpoint, headers=headers, data=json.dumps(data), timeout=15)
        response.raise_for_status()  # HTTP 에러 시 예외 발생
        resp_json = response.json()
        return resp_json["choices"][0]["message"]["content"]
    except Exception as e:
        err_msg = f"[Error] GPT API call failed: {type(e).__name__}, {e}"
        print(err_msg)
        return err_msg

def answer_query(query, store, history=None, top_k=3):
    """
    RAG 파이프라인 + 예외처리
    :param query: 사용자 질의
    :param store: LocalFaissStore
    :param history: 이전 대화 히스토리
    :param top_k: 검색할 상위 k개 chunk
    :return: { "answer": "...", "sources": [...] }
    """
    if not query or store is None:
        return {
            "answer": "[Error] Invalid query or store is None",
            "sources": []
        }

    if history is None:
        history = []

    # 1) query 임베딩
    query_embedding = embed_chunks([query])[0]
    if query_embedding is None:
        return {
            "answer": "[Error] Failed to create query embedding",
            "sources": []
        }

    # 2) store.search(query_embedding, top_k)
    results = store.search(query_embedding, top_k=top_k)
    if not results:
        # 검색 결과 없으면
        return {
            "answer": "죄송하지만 해당 질문에 대해 적절한 답변을 찾지 못했습니다.",
            "sources": []
        }

    # 3) chunk context
    context_texts = []
    sources = []
    for dist, meta in results:
        snippet = meta.get('text_snippet', '')
        title = meta.get('title', 'Untitled')
        url = meta.get('url', '')
        chunk_idx = meta.get('chunk_index', 0)

        context_texts.append(f"[{title}#{chunk_idx}] {snippet}")
        sources.append({
            "title": title,
            "url": url,
            "distance": dist
        })

    combined_context = "\n".join(context_texts)

    # 4) GPT 호출
    api_key = os.getenv("OPENAI_API_KEY", "DUMMY_KEY")
    model = os.getenv("GPT_MODEL", "gpt-4")
    temperature = float(os.getenv("TEMPERATURE", "0.7"))
    max_tokens = int(os.getenv("MAX_TOKENS", "1000"))

    prompt = f"User query: {query}\n\nContext:\n{combined_context}\n\nProvide a helpful answer referencing the content above."
    gpt_answer = call_gpt(
        context=prompt,
        api_key=api_key,
        model=model,
        temperature=temperature,
        max_tokens=max_tokens
    )

    return {
        "answer": gpt_answer,
        "sources": sources
    }
PYTHON

#############################################
# 3. update_pipeline.py (ingestion 시 예외처리)
#############################################
echo "Updating update_pipeline.py..."
cat <<'PYTHON' > project/modules/update_pipeline.py
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
PYTHON

#############################################
# 완료 메시지
#############################################
echo "=== Done: Hour 8 - Exception Handling & Code Clean-up. ==="
echo "Try running your end-to-end test again:"
echo "  cd project"
echo "  source ../.venv/bin/activate"
echo "  python test_end_to_end.py"
