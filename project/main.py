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
