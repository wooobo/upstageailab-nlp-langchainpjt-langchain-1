#!/usr/bin/env bash
#
# step10.sh: Hour 10 - 최종 점검 & 데모
# - Checks config.env values
# - Runs test_end_to_end.py
# - Provides a short demo scenario

echo "=== [Hour 10] Final Check & Demo Script ==="

#############################################
# 1. 사전 점검 (config.env, 폴더 구조 등)
#############################################

CONFIG_FILE="project/config.env"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[Error] $CONFIG_FILE not found. Make sure your project is set up correctly."
  exit 1
fi

# 필수 파라미터 (예시): OPENAI_API_KEY, GPT_MODEL
OPENAI_API_KEY=$(grep '^OPENAI_API_KEY=' "$CONFIG_FILE" | cut -d= -f2 | tr -d '"')
GPT_MODEL=$(grep '^GPT_MODEL=' "$CONFIG_FILE" | cut -d= -f2 | tr -d '"')

if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "YOUR_API_KEY" ]; then
  echo "[Warning] OPENAI_API_KEY is not set or still 'YOUR_API_KEY'. GPT 실제 호출 시 에러가 날 수 있습니다."
fi

if [ -z "$GPT_MODEL" ]; then
  echo "[Warning] GPT_MODEL is not set. Defaulting to 'gpt-4' in code, or stub mode."
fi

if [ ! -d "project/docs" ]; then
  echo "[Warning] project/docs 폴더가 없습니다. PDF 파일, sample.pdf 등이 올바로 위치해야 합니다."
fi

echo "[Check] config.env & folder structure check complete."

#############################################
# 2. 전체 파이프라인 자동 테스트
#############################################
echo "=== Running end-to-end test (test_end_to_end.py) ==="
cd project
source ../.venv/bin/activate

if [ ! -f "test_end_to_end.py" ]; then
  echo "[Error] test_end_to_end.py not found in 'project/'."
  echo "Please ensure your Hour 7 script was completed."
  exit 1
fi

python test_end_to_end.py

echo "=== End-to-end test finished. ==="

#############################################
# 3. 데모 시연 안내
#############################################
echo
echo "=== [DEMO GUIDANCE] ==="
echo "1) Textual TUI 시연:"
echo "   python textual_app.py"
echo "   - 터미널 상에서 UI가 뜨고, 질문 입력 시 RAG + GPT 스텁 응답을 볼 수 있습니다."
echo
echo "2) 주요 질문 예시:"
echo "   - '휴가 신청은 어떻게 하나요?'"
echo "   - '이번주 시간표 알려줘'"
echo "   - '출석가이드 문서 좀 볼 수 있어?'"
echo
echo "3) 답변 & 출처 확인:"
echo "   - 답변 텍스트 끝에 [Sources] 리스트가 출력되어, 참조된 문서 타이틀과 거리(dist) 표시"
echo
echo "4) 데모 종료:"
echo "   - Textual UI 상에서 Ctrl + C 를 누르면 종료됩니다."
echo
echo "=== [Hour 10] Final Check & Demo Complete ==="

