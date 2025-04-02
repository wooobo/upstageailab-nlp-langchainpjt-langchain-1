#!/usr/bin/env bash
#
# step6.sh: Hour 6 - Textual TUI 기본 구성
# - Creates textual_app.py for a simple chat interface using Textual
# - Updates main.py to hint using textual_app.py

echo "=== Start: Hour 6 - Textual TUI ==="

#############################################
# 1. textual_app.py 생성
#############################################
echo "Creating textual_app.py..."
cat <<'PYTHON' > project/textual_app.py
#!/usr/bin/env python3

import os
from dotenv import load_dotenv
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, TextLog, Input

from modules.vectorstore import LocalFaissStore
from modules.update_pipeline import update_documents_if_needed
from modules.rag import answer_query

"""
Hour 6: Textual TUI 기본 구현
 - ChatApp: 간단한 채팅 UI
 - 사용자가 입력 -> RAG(answer_query) 호출 -> 메시지 출력
"""

class ChatApp(App):
    CSS_PATH = None  # (원하면 CSS 파일 경로 지정 가능)
    BINDINGS = [
        ("ctrl+c", "quit", "Quit"),
    ]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.store = None
        self.history = []  # (user_msg, assistant_msg) 튜플 보관
        self.max_history = 5

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield TextLog(id="chat_log")
        yield Input(placeholder="질문을 입력하고 [Enter]를 눌러주세요...", id="chat_input")
        yield Footer()

    def on_mount(self):
        # .env 로드 & Store 생성 & 업데이트 체크
        load_dotenv(dotenv_path="config.env")
        self.store = LocalFaissStore(dimension=768)
        self.refresh_documents()

    def on_input_submitted(self, event: Input.Submitted) -> None:
        user_input = event.value.strip()
        if not user_input:
            return
        event.input.value = ""  # 입력창 비우기

        # 화면에 사용자 메시지 출력
        chat_log = self.query_one("#chat_log", TextLog)
        chat_log.write(f"[bold green]User:[/bold green] {user_input}")

        # RAG 호출
        assistant_msg = self.get_rag_answer(user_input)
        chat_log.write(f"[bold cyan]Assistant:[/bold cyan] {assistant_msg}")

        # history 관리 (옵션)
        self.history.append((user_input, assistant_msg))
        if len(self.history) > self.max_history:
            self.history.pop(0)

    def refresh_documents(self):
        """Hour 4: update_documents_if_needed 호출"""
        store, updated = update_documents_if_needed(self.store)
        self.store = store
        if updated:
            msg = "[System] Documents updated (ingest & embed)."
        else:
            msg = "[System] No update needed."
        self.query_one("#chat_log", TextLog).write(msg)

    def get_rag_answer(self, query: str) -> str:
        """RAG 파이프라인 호출 (Hour 5)"""
        # history를 사용할 수도 있지만, 여기서는 간단히 None
        rag_result = answer_query(query, store=self.store, history=None, top_k=3)
        # answer + sources
        answer_text = rag_result["answer"]
        # sources 예시 표시
        src_info = "\n".join([
            f" - {src['title']} (dist={src['distance']:.2f})"
            for src in rag_result["sources"]
        ])
        # Assistant 출력 메시지 합성
        return f"{answer_text}\n[Sources]\n{src_info}"

if __name__ == "__main__":
    app = ChatApp()
    app.run()
PYTHON

chmod +x project/textual_app.py

#############################################
# 2. main.py 수정 (Textual 사용 안내)
#############################################
echo "Updating main.py..."
cat <<'PYTHON' > project/main.py
#!/usr/bin/env python3

"""
이전 단계(Hour 5)까지의 main.py 로직은 그대로 남겨두고,
Textual TUI를 사용하려면 `python textual_app.py`를 실행하라는 안내만 표시합니다.
"""

def main():
    print("[Main.py Notice]")
    print("이제 Textual TUI를 통해 질의응답을 진행하려면:")
    print("   python textual_app.py")
    print("을 실행하세요.")
    print("혹은 Hour 5 방식으로 RAG 테스트를 하려면, main.py를 직접 수정해 주세요.")

if __name__ == "__main__":
    main()
PYTHON

echo "=== Done (Hour 6) ==="
echo "Now run the following to test the Textual UI:"
echo "  cd project"
echo "  source ../.venv/bin/activate"
echo "  python textual_app.py"
