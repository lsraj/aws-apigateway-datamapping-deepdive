
# run: python3 gwTest.py

import requests
from dotenv import load_dotenv
import os

# pip install python-dotenv
# Load environment variables from .env file
load_dotenv()

API_GATEWAY_BASE_URL = os.getenv("API_GATEWAY_BASE_URL")

def test_agify():
    req_headers = {}
    req_headers['Content-Type'] = 'application/json'
    url = f'{API_GATEWAY_BASE_URL}/v1/api/agify'
    names = ["tiger", "lion", "tom", "forest"]
    for name in names:
        req_params = {"n" : name}
        # sends request as url?n=name
        resp = requests.get(url, params=req_params, headers=req_headers)
        print(f"test_agify(): {name} info: {resp.json()}")

def test_ipgeo():
    req_headers = {}
    req_headers['Content-Type'] = 'application/json'
    url = f'{API_GATEWAY_BASE_URL}/v1/api/ipgeo'
    resp = requests.get(url, headers=req_headers)
    print(f"test_ipgeo(): whoami: {resp.json()}")


def test_ipinfo():
    req_headers = {}
    req_headers['Content-Type'] = 'application/json'
    ips = ["1.1.1.1", "1.1.1.2", "1.2.3.4"]
    for ip in ips:
        url = f'{API_GATEWAY_BASE_URL}/v1/api/ipinfo/{ip}'
        resp = requests.get(url, headers=req_headers)
        print(f"test_ipinfo(): {ip}: {resp.json()}")

def main():
    test_agify()
    test_ipgeo()
    test_ipinfo()

if __name__ == "__main__":
    main()
