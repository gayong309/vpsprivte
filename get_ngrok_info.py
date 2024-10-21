import sys
import json
import requests

def get_ngrok_info():
    response = requests.get("http://localhost:4040/api/tunnels")
    data = response.json()
    tunnel = data['tunnels'][0]
    public_url = tunnel['public_url']
    ip = public_url.split('//')[1].split(':')[0]
    port = public_url.split(':')[1]
    return f'SSH Info:\nssh root@{ip} -p {port}\nROOT Password:{PASSWORD}'

if __name__ == "__main__":
    PASSWORD = sys.argv[1]  # Get password from command line argument
    print(get_ngrok_info())
