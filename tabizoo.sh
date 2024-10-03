#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 색상 초기화

# 1. 파이썬 및 필요한 패키지 설치
echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
sudo apt update
sudo apt install -y python3 python3-pip git

# 2. 기존 작업 공간 삭제 (존재할 경우)
if [ -d "~/tabizoo" ]; then
    echo -e "${YELLOW}기존 작업 공간을 삭제 중...${NC}"
    rm -rf ~/tabizoo
fi

# 3. 작업 공간 생성 및 이동
echo -e "${YELLOW}작업 공간 생성 및 이동 중...${NC}"
mkdir -p ~/tabizoo
cd ~/tabizoo

# 4. GitHub에서 코드 복사
echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
git clone https://github.com/KangJKJK/tabizoo-base.git .
pip3 install -r requirements.txt

# 5. 사용자에게 query_id 입력 안내
echo -e "${GREEN}여러개의 Tabizoo를 구동하기 위해서는 각 query_id마다 같은 개수의 프록시가 필요합니다.${NC}"
echo -e "${GREEN}query_id를 얻는 방법은 텔레그램 그룹방을 참고하세요.${NC}"
read -p "query_id를 입력하세요: " query_id
echo "$query_id" > data.txt

# 6. 프록시 사용 여부 확인
echo -e "${YELLOW}프록시를 사용하시겠습니까? (1: 예, 2: 아니오)${NC}"
read -p "선택: " use_proxy

if [ "$use_proxy" -eq 1 ]; then
    # 1번 선택시 (프록시 사용)
    echo -e "${RED}프록시의 개수와 query_id 개수가 같아야 합니다.${NC}"
    echo -e "${RED}프록시를 다음 형식으로 입력하세요: http://user:pass@ip:port${NC}"
    echo -e "${RED}여러 개의 프록시를 사용할 경우 줄바꿈으로 구분하세요.${NC}"
    read -p "프록시를 입력하세요: " proxies

    # data-proxy.json 파일에 프록시 정보 입력
    echo "{\"accounts\": [" > data-proxy.json
    for proxy in $proxies; do
        echo "{\"acc_info\": \"$query_id\", \"proxy_info\": \"$proxy\"}," >> data-proxy.json
    done
    echo "]}" >> data-proxy.json

    # 오토스핀 및 오토업그레이드 설정
    read -p "오토스핀을 사용하시겠습니까? (y/n): " auto_spin
    read -p "오토업그레이드를 사용하시겠습니까? (y/n): " auto_upgrade

    if [ "$auto_spin" == "y" ]; then
        sed -i 's/"auto-spin": "false"/"auto-spin": "true"/' config.json
        read -p "스핀 배팅값을 입력하세요 (1~3): " spin_bet
        sed -i "s/process_spin(data=data, multiplier=1, proxies=proxies)/process_spin(data=data, multiplier=$spin_bet, proxies=proxies)/" bot-proxy.py
    fi

    if [ "$auto_upgrade" == "y" ]; then
        sed -i 's/"auto-upgrade": "false"/"auto-upgrade": "true"/' config.json
    fi

    # 봇 실행
    echo -e "${GREEN}봇을 실행합니다...${NC}"
    python3 bot-proxy.py

else
    # 2번 선택시 (프록시 사용 안함)
    # 오토스핀 및 오토업그레이드 설정
    read -p "오토스핀을 사용하시겠습니까? (y/n): " auto_spin
    read -p "오토업그레이드를 사용하시겠습니까? (y/n): " auto_upgrade

    if [ "$auto_spin" == "y" ]; then
        sed -i 's/"auto-spin": "false"/"auto-spin": "true"/' config.json
        read -p "스핀 배팅값을 입력하세요 (1~3): " spin_bet
        sed -i "s/process_spin(data=data, multiplier=1)/process_spin(data=data, multiplier=$spin_bet)/" bot.py
    fi

    if [ "$auto_upgrade" == "y" ]; then
        sed -i 's/"auto-upgrade": "false"/"auto-upgrade": "true"/' config.json
    fi

    # 봇 실행
    echo -e "${GREEN}봇을 실행합니다...${NC}"
    python3 bot.py
fi