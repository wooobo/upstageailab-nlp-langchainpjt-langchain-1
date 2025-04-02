#!/usr/bin/env bash
#
# step2.sh (수정본):
#  - 추가 스크립트 없이, 곧바로 document_loader.py, update_pipeline.py, main.py를 덮어씌움
#  - ingestion (Hour 2) 관련 스텁 코드가 바로 반영됨

echo "=== Start: Updating ingestion stubs directly ==="

#############################################
# 1. document_loader.py 생성/덮어쓰기
#############################################
echo "Updating document_loader.py..."
cat <<'PYTHON' > project/modules/document_loader.py
import os
import requests
import tempfile

"""
 Hour 2: 문서 ingestion 설계 및 초기 구현 (스텁 버전)
 - Google Docs -> PDF 변환 (convert_gdoc_to_pdf)
 - PDF -> 텍스트 추출 (extract_text_from_pdf)
 - Upstage OCR API 스텁 (run_ocr_on_pdf)
 - 노션 문서 내용/이미지 링크 추출 스텁 (fetch_notion_content)
"""

def convert_gdoc_to_pdf(doc_url: str) -> str:
    """
    [STUB] Google Docs/Slides/Sheets를 PDF로 변환하는 함수.
    실제로는 Google Drive API or Export Link를 써야 하지만
    MVP에서는 스텁으로 처리.
    :param doc_url: 구글 문서 URL
    :return: 변환된 PDF 파일 경로 (로컬)
    """
    # 실제 구현 시:
    #  1) doc_url에서 문서 ID 추출
    #  2) Google API를 통해 export -> PDF bytes
    #  3) 임시파일 또는 docs/sample.pdf 로 저장 후 경로 반환
    # 여기서는 예시로 docs/sample.pdf 라는 고정 파일 사용
    pdf_path = "docs/sample.pdf"
    return pdf_path

def extract_text_from_pdf(pdf_path: str) -> str:
    """
    [STUB] PDF 파일에서 텍스트를 추출하는 함수.
    PyPDF2, pdfplumber, etc. 라이브러리를 활용 가능.
    :param pdf_path: 로컬 PDF 경로
    :return: 추출된 텍스트 (예시)
    """
    # 간단히 스텁으로 "PDF 내용"이라는 텍스트 반환
    # 실제 구현 시 pdfplumber / PyPDF2 + 전처리를 적용
    extracted_text = "PDF 내용 (예시)"
    return extracted_text

def run_ocr_on_pdf(pdf_path: str) -> str:
    """
    [STUB] Upstage OCR API 호출 스텁
    만약 PDF 내 표/이미지 등 별도 OCR이 필요하다면 이 함수를 사용.
    :param pdf_path: 로컬 PDF 경로
    :return: OCR 결과 텍스트
    """
    # 실제 구현 시:
    # with open(pdf_path, 'rb') as f:
    #     files = {'file': f}
    #     response = requests.post("UPSTAGE_OCR_ENDPOINT", files=files)
    #     ...
    # return response.text
    return "OCR 결과 텍스트 (예시)"

def fetch_notion_content(notion_url: str) -> (str, list):
    """
    [STUB] 노션 문서 내용과 이미지 링크 추출 함수.
    실제로는 Notion API 혹은 Public Access된 HTML 파싱 등을 해야 함.
    :param notion_url: 노션 페이지 URL
    :return: (노션 문서 전체 텍스트, [이미지 링크 목록])
    """
    # 여기서는 간단히 스텁.
    text_content = "노션 문서 내용 (예시)"
    image_links = [
        "https://notion.so/image1.png",
        "https://notion.so/image2.png"
    ]
    return text_content, image_links
PYTHON


#############################################
# 2. update_pipeline.py 생성/덮어쓰기
#############################################
echo "Updating update_pipeline.py..."
cat <<'PYTHON' > project/modules/update_pipeline.py
import time
import os
from .document_loader import convert_gdoc_to_pdf, extract_text_from_pdf, run_ocr_on_pdf, fetch_notion_content

"""
Hour 2: ingest_all_documents (초기 구현 스텁)
- DOCUMENTS 목록을 순회하며, 구글 문서는 PDF 변환 -> 텍스트 추출
- 노션 문서는 텍스트/이미지 링크 추출
- (OCR 활용 예시도 스텁)
"""

# 예시 문서 목록 (실제로는 CSV나 DB에서 불러올 수도 있음)
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

def ingest_all_documents():
    """
    [MVP] 모든 문서를 순회하며 텍스트를 얻고,
    추후 임베딩 파이프라인에 넘길 준비를 하는 스텁.
    """
    all_contents = []

    for doc in DOCUMENTS:
        doc_type = doc.get("type")
        doc_url = doc.get("url")
        doc_title = doc.get("title")

        if "google" in doc_type:
            # 1) 구글 문서 -> PDF 변환
            pdf_path = convert_gdoc_to_pdf(doc_url)
            # 2) PDF -> 텍스트 추출
            extracted = extract_text_from_pdf(pdf_path)
            # 3) OCR 필요 시 (스텁)
            # ocr_result = run_ocr_on_pdf(pdf_path)

            all_contents.append({
                "title": doc_title,
                "type": doc_type,
                "url": doc_url,
                "text": extracted
                # "ocr_text": ocr_result
            })

        elif doc_type == "notion":
            # 노션 문서 -> (텍스트, 이미지링크)
            text_content, image_links = fetch_notion_content(doc_url)
            all_contents.append({
                "title": doc_title,
                "type": doc_type,
                "url": doc_url,
                "text": text_content,
                "images": image_links
            })
        else:
            # 기타 타입에 대한 처리
            pass

    return all_contents
PYTHON

#############################################
# 3. main.py 덮어쓰기
#############################################
echo "Updating main.py..."
cat <<'PYTHON' > project/main.py
#!/usr/bin/env python3

import os
from dotenv import load_dotenv
from modules.update_pipeline import ingest_all_documents

def main():
    # .env 불러오기
    load_dotenv(dotenv_path='config.env')

    # 문서 ingestion 테스트
    contents = ingest_all_documents()
    print("[Ingestion Test] Fetched contents:")
    for c in contents:
        print("Title:", c["title"])
        print("URL:", c["url"])
        print("Type:", c["type"])
        print("Text snippet:", c["text"][:30], "...")
        print("Images:", c.get("images", []))
        print("-" * 40)

    print("Ingestion complete. (Stub data)")

if __name__ == "__main__":
    main()
PYTHON

echo "main.py updated."

echo "=== Done! Now you can run the following to test: ==="
echo "  cd project"
echo "  source ../.venv/bin/activate"
echo "  python main.py"
