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
