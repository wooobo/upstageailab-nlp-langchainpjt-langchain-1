#!/usr/bin/env bash

########################
# 1. 프로젝트 디렉토리 구조 생성
########################
mkdir -p project/modules project/docs project/embeddings

# 필수 파일들 생성
touch project/requirements.txt
touch project/config.env
touch project/main.py
touch project/modules/document_loader.py
touch project/modules/embedding.py
touch project/modules/vectorstore.py
touch project/modules/rag.py
touch project/modules/update_pipeline.py

echo "Project folder structure created."

########################
# 2. 가상환경 생성 & 활성화
########################
python3 -m venv .venv
source .venv/bin/activate

########################
# 3. requirements.txt 작성
########################
cat <<REQ > project/requirements.txt
langchain
faiss-cpu
pdfplumber
PyPDF2
requests
python-dotenv
textual
REQ

echo "requirements.txt created."

########################
# 4. 의존성 패키지 설치
########################
cd project
pip install -r requirements.txt
cd ..

echo "Dependencies installed."

########################
# 5. config.env 기본 템플릿 생성
########################
cat <<ENV > project/config.env
OPENAI_API_KEY="YOUR_API_KEY"
GPT_MODEL="gpt-4"
EMBEDDING_MODEL="text-embedding-ada-002"
VECTORSTORE_TOPK=3
UPDATE_INTERVAL_HOURS=24
TEMPERATURE=0.7
MAX_TOKENS=1500
ENV

echo "config.env created."

########################
# 6. main.py 스켈레톤 생성
########################
cat <<PY > project/main.py
#!/usr/bin/env python3

import os
from dotenv import load_dotenv

def main():
    # .env 불러오기
    load_dotenv(dotenv_path='config.env')

    api_key = os.getenv("OPENAI_API_KEY")
    print("Hello from main.py!")
    print("Loaded OPENAI_API_KEY:", api_key)

if __name__ == "__main__":
    main()
PY

echo "main.py created."

########################
# 완료 메시지
########################
echo "Project setup complete! Now you can run:"
echo "    cd project"
echo "    source ../.venv/bin/activate  (to re-activate venv)"
echo "    python main.py"
