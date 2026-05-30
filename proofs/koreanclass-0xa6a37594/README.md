# 세상에서 제일 쉬운 블록체인 강의 (Korean blockchain class invite)

| Field | Value |
|-------|-------|
| Address | `0xa6a3759434ff294f1af8c5429e3918bd1efd1216` |
| Deployed | July 2018 (block 5,955,504) |
| Class | "Easiest blockchain class in the world; Pablock" |
| Session date | July 12, 2018, 7:30 PM |
| Venue | Seoul, Seocho-gu, Bangbaecheon-ro 14-gil 7, 2F "The Air" |
| Runtime size | 2,085 bytes |
| Verification | Unverified on Etherscan |

## What this contract is

A class organizer wrote the event recap directly into a contract: title, date, venue, the full attendee roster (30 names plus "and Pablo"), and sponsorship credits. The body is returned by selector `0x8a4d5a67` as a Solidity string whose contents are themselves a hex-encoded UTF-8 byte sequence (an extra layer of encoding the author used to be safe with non-ASCII bytes).

## The invite (decoded)

```
세상에서 제일 쉬운 블록체인 강의; 파블록

첫번째 강연 성공적으로 완료

일시 : 2018년 7월 12일 목요일 오후 7시 30분
장소 : 서울 서초구 방배천로 14길 7 2층 디에어
참가인원 : 김애진, 서용진, 송영종, 서연주, 이한솔, 문설화, 김수봉, 최성웅, 김범준, 이나경, 진은정, 강민수, 홍지혜, 조승현, 이동혁, 서한울, 류정현, 이원주, 이웅, 오세종, 김현근, 성미현, 조주현, 제니퍼 왕, 박성의, 강희수, 김동현, 윤준탁, 김혁주, 그리고 파블로
후원 : 인블록, 디에어, 파블로플러스체인
참가자 전원 30,000 파블로플러스 에어드랍
```

English summary: "The easiest blockchain class in the world; Pablock. First lecture successfully completed. Date: Thursday, July 12, 2018, 7:30 PM. Venue: 2F The Air, 14-gil 7 Bangbaecheon-ro, Seocho-gu, Seoul. Attendees: [30 names], and Pablo. Sponsors: Inblock, The Air, Pablo Plus Chain. All attendees received an airdrop of 30,000 Pablo Plus."

## How to reproduce

```bash
curl -s -H 'User-Agent: Mozilla/5.0' -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0xa6a3759434ff294f1af8c5429e3918bd1efd1216","data":"0x8a4d5a67"},"latest"],"id":1}' \
  https://ethereum-rpc.publicnode.com | python3 -c "
import sys, json
r = json.load(sys.stdin)['result']
b = bytes.fromhex(r[2:])
off = int.from_bytes(b[0:32], 'big')
ln = int.from_bytes(b[off:off+32], 'big')
hex_text = b[off+32:off+32+ln].decode()
print(bytes.fromhex(hex_text[2:]).decode('utf-8'))
"
```

## Files

- `invite.txt`, the fully decoded Korean text.
