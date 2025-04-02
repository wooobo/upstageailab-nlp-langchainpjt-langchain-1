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

