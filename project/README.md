# 프로젝트: 부트 캠프 학원 매니저 Q/A (LangChain 기반)

본 프로젝트는 LangChain을 활용한 **RAG(Retrieval-Augmented Generation)** 방식의 Q&A 서비스를 구현합니다.

---

## 1. 개요

- 여러 문서(구글 Docs, 노션, PDF 등)를 로컬에서 수집·임베딩(FAISS)하고, GPT 모델과 결합해 **챗봇 형태**로 질의응답을 제공합니다.
- Python 터미널 환경에서 동작하며, [Textual](https://github.com/Textualize/textual)을 사용해 CLI 기반 UI를 제공합니다.
- “휴가신청 프로세스는?”, “오늘 시간표가 어때?” 등 질문에 대해 관련 문서 내용을 찾아 GPT 답변 + 출처 링크를 제시합니다.

---

## 2. 설치 및 실행

### (1) 가상환경 및 의존성 설치

```bash
# 프로젝트 루트에서
python3 -m venv .venv
source .venv/bin/activate

# Hour 1에서 생성된 requirements.txt 설치
pip install -r requirements.txt
