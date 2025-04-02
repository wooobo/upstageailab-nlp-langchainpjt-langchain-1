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
