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
