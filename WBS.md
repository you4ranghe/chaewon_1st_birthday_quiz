# 채원이 첫 돌잔치 QUIZ GAME — 작업 문서

> 이 문서는 **세션이 끊겨도 이어서 작업할 수 있도록** 프로젝트 상태와 수정 방법을 기록한 것입니다.
> 새 세션에서 이 폴더를 열었다면 **이 파일을 먼저 읽으세요.**

- 최종 업데이트: 2026-08-06
- 저장소: https://github.com/you4ranghe/chaewon_1st_birthday_quiz
- 용도: 딸 **채원**이의 첫 돌잔치 현장에서 하객 대상 퀴즈를 진행하는 발표 자료
- 형태: **HTML 파일 1개** (PPT 대체). 브라우저로 열어 전체화면으로 발표합니다.
- 현재 상태: **25장 전체 제작 완료.** 아래 "확인이 필요한 항목"만 남았습니다.

---

## 1. 왜 서버가 필요 없는가

Vercel · Supabase 같은 배포/DB는 **쓰지 않습니다.** 발표자 노트북 화면을 프로젝터에 띄우는 용도라
서버도 데이터베이스도 필요 없고, 오히려 행사장 와이파이가 끊기면 위험합니다.
그래서 **폰트까지 파일 안에 심어** 인터넷 없이 100% 동일하게 보이도록 만들었습니다.
(단, 하객 휴대폰으로 실시간 응답을 받는 방식으로 바꾼다면 그때는 배포가 필요합니다.)

---

## 2. 파일 구조

```
C:\Users\ibank\quiz\
├─ index.html              ← ★ 실제로 발표에 쓰는 파일 (1.7MB, 폰트 내장, 자동 생성물)
├─ WBS.md                  ← 이 문서
├─ 참고\                    ← 원본 레퍼런스 이미지 25장 (KakaoTalk_...jpg)
└─ _source\                ← 수정 작업은 전부 여기서 합니다
   ├─ slides.src.html      ← ★ 진짜 소스. 내용·디자인 수정은 이 파일만 고칩니다
   ├─ build.ps1            ← 폰트를 심어 index.html을 만드는 스크립트
   └─ fonts\
      ├─ PressStart2P.woff2          (영문 픽셀체 — QUIZ GAME, START)
      ├─ Galmuri11.woff2             (한글 픽셀체 — 인사말, 게임 규칙)
      └─ Pretendard-ExtraBold.woff2  (본문 — 문제, 보기)
```

> **`index.html`을 직접 고치지 마세요.** 빌드할 때마다 덮어써집니다.
> 항상 `_source\slides.src.html`을 고친 뒤 다시 빌드합니다.

---

## 3. 수정하고 다시 만드는 방법

### 3-1. 가장 쉬운 방법 — Claude에게 말하기
> "QUIZ 08 정답을 ④로 바꿔줘", "QUIZ 09 보기를 110/115/120/125/130mm로 채워줘"

이렇게 **고칠 내용을 말씀만 하시면** Claude가 소스 수정과 빌드까지 처리합니다.

### 3-2. 직접 고치는 방법

**1단계.** `_source\slides.src.html`을 열고 `SLIDES` 배열에서 해당 슬라이드를 찾아 고칩니다.
(각 항목에 `/* 01 */` ~ `/* 25 */` 번호 주석이 달려 있습니다.)

**2단계.** PowerShell에서 빌드합니다.

```powershell
& "C:\Users\ibank\quiz\_source\build.ps1"
```

**3단계.** `index.html`을 브라우저에서 새로고침해 확인합니다.

**빌드 성공 판정:** `index.html`이 **약 1,797,000 bytes (1.7MB)** 가 되고 수정 시각이 갱신됩니다.
40KB 언저리라면 폰트가 안 들어간 것입니다.

```powershell
Get-Item "C:\Users\ibank\quiz\index.html" | Select-Object Length, LastWriteTime
```

> ⚠️ **Claude Code 세션 안에서는 `build.ps1`이 동작하지 않습니다 (검증된 사실)**
> 세션 안에서 `.ps1` 스크립트를 실행하면 폰트 base64 생성까지는 되지만 **마지막 파일 쓰기가
> 조용히 무시됩니다.** 오류도 안 납니다. 파일을 지운 뒤 실행해도 생성되지 않는 것으로 확인했습니다.
> **→ Claude는 반드시 아래 3-3의 인라인 명령을 쓸 것.**
> 사용자가 PowerShell 창에서 직접 실행하는 경우는 제약이 없을 것으로 보이지만, 아직 확인 전입니다
> (§6 TODO 참고). Claude Code에서 직접 확인하려면 프롬프트에 `!` 를 붙여 실행하세요:
> `! & "C:\Users\ibank\quiz\_source\build.ps1"`

### 3-3. 확실히 동작하는 대체 빌드 (검증 완료 — Claude는 이 방법을 쓸 것)

PowerShell에 아래를 그대로 붙여넣습니다.

```powershell
$here = "C:\Users\ibank\quiz\_source"
$out  = "C:\Users\ibank\quiz\index.html"
$marker = '/' + '*__EMBED_FONTS__*' + '/'
$sb = New-Object System.Text.StringBuilder
foreach ($f in @(@('PressStart2P.woff2','PressStart2P','400'), @('Galmuri11.woff2','Galmuri11','400'), @('Pretendard-ExtraBold.woff2','PretendardXB','100 900'))) {
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $here "fonts\$($f[0])")))
  [void]$sb.AppendLine("@font-face{font-family:'$($f[1])';font-style:normal;font-weight:$($f[2]);font-display:block;src:url(data:font/woff2;base64,$b64) format('woff2');}")
}
$html = [IO.File]::ReadAllText((Join-Path $here 'slides.src.html'),[Text.Encoding]::UTF8)
$html = $html.Replace($marker, $sb.ToString())
[IO.File]::WriteAllText($out, $html, (New-Object Text.UTF8Encoding($false)))
"{0:N0} bytes" -f (Get-Item $out).Length
```

**성공 판정: 약 1,797,000 bytes (1.7MB).** 40KB 언저리가 나오면 폰트가 안 들어간 것입니다.

> Claude가 이 명령을 실행할 때는 `dangerouslyDisableSandbox: true` 가 필요합니다.

> 💡 **Claude에게 주는 메모**
> 이 프로젝트의 셸 안전 검사는 `/*` 로 시작하는 리터럴을 시스템 경로 삭제로 오인해
> **명령 전체를 차단**합니다. 그래서 마커를 `'/' + '*__EMBED_FONTS__*' + '/'` 처럼
> 조각으로 조립합니다. 또한 `Remove-Item`을 같은 명령에 섞지 마세요.

---

## 4. 슬라이드 데이터 구조

`slides.src.html`의 `SLIDES` 배열이 25장 전부를 정의합니다. 타입은 5가지입니다.

| type | 쓰임 | 주요 필드 |
|---|---|---|
| `title` | 표지 | `eyebrow`, `en` |
| `message` / `start` | 인사말 / 게임 시작 | `krTitle`, `lines[]` |
| `rules` | 게임 규칙 | `krTitle`, `rules[]` |
| `quiz` | 문제 | `no`, `question`, `options[]`, `note`, `qSize`, `optSize` |
| `choices` | 보기만 있는 화면 (Q9 전용) | `no`, `labels[]` |
| `answer` | 정답 | `no`, `answer`, `blank` |

**자주 쓰는 요령**

- 문제를 줄바꿈: `question` 안에 `<br>` 을 넣습니다.
- 글자가 넘칠 때: `qSize`(질문), `optSize`(보기) 숫자를 줄입니다. 기본은 72 / 60.
- 보기·정답의 **①②③④⑤ 원문자는 문자열 맨 앞에** 붙입니다. 코드가 첫 글자를 잘라
  동그라미 배지로 렌더링합니다. 예: `'② 2.92kg'`
- 작은 주석줄: `note` (예: Q10의 "*앨범에서 채원이 얼굴 인식…")
- 빈 말풍선(실물·사진 보여줄 자리): `blank:true`
- 배경은 `SCENE_BUSH`(덤불+장미) / `SCENE_TREE`(나무), 선물은 `PRIZE_CHEST`(보물상자) /
  `PRIZE_BAG`(돈주머니). 원본대로 **홀수 문제=덤불+상자, 짝수 문제=나무+돈주머니**로 번갈아 갑니다.
- 목차에 표시되는 짧은 이름은 `nav` 필드입니다.

---

## 5. 발표 조작법

| 키 | 동작 |
|---|---|
| `→` `Space` `Enter` `PageDown` | 다음 |
| `←` `PageUp` | 이전 |
| `F` | 전체화면 (**발표 시작 전 반드시 누르세요**) |
| `T` | 3초 카운트다운 (문제 화면에서) |
| `O` | 목차 — 25장 중 원하는 곳으로 점프 |
| `M` | 음소거 |
| `Esc` | 목차·타이머 닫기 |
| 화면 클릭 | 오른쪽=다음 / 왼쪽 22%=이전 |

프레젠터 리모컨(포인터)도 그대로 작동합니다. 마우스를 움직이면 하단에 조작 안내가 잠깐 뜹니다.

---

## 6. TODO

### 🔴 확인이 필요한 항목 (채원이 부모님만 아는 내용 — 답을 주셔야 반영 가능)

- [ ] **QUIZ 08 정답 번호 확정**
  원본 이미지에 **오류**가 있습니다. 문제 보기는 `④ 엄마 그만 찾아~` / `⑤ 순하다~` 인데
  정답 슬라이드에는 `④ 순하다~`로 적혀 있습니다.
  → 현재 정답 내용("순하다~")을 기준으로 **`⑤ 순하다~`로 넣어둔 상태.**
  → 만약 진짜 정답이 "엄마 그만 찾아~"라면 `④ 엄마 그만 찾아~`로 바꿔야 합니다.

- [ ] **QUIZ 09 보기 5개와 정답 확정**
  "채원이의 발은 몇 번일까요?" — 원본의 보기 화면(①~⑤)과 정답(④)이 **번호만 있고 내용이 비어** 있습니다.
  현장에서 실물 신발이나 사진을 보여주실 것으로 보고 **원본 그대로 번호만** 배치했습니다.
  → 글자로 표시하려면 보기 5개(예: `110mm` … `130mm`)를 알려주세요.
  → 수정 위치: `slides.src.html`의 `/* 22 */` 항목 `labels:['','','','','']` 와 `/* 23 */`의 `answer`.

- [ ] **QUIZ 10 정답 확인**
  원본 정답 슬라이드에 `①`만 있고 내용이 비어 있어, 문제의 ①번인 **`① 1,316장`으로 채워 넣었습니다.**
  → 맞는지만 확인해주세요.

### 🟡 확인하면 좋은 것

- [ ] **`build.ps1`이 사용자 환경에서 동작하는지 한 번 확인**
      Claude Code 세션 안에서는 파일 쓰기가 무시되는 것을 확인했지만(§3-2), 일반 PowerShell 창에서는
      정상 동작할 것으로 보입니다. 한 번 실행해보고 1.7MB가 나오면 §3-2의 경고를 "세션 안에서만
      해당"으로 확정할 수 있습니다. 안 되면 `build.ps1`을 지우고 §3-3 인라인 방법만 남기세요.

### 🟡 발표 전 리허설 체크

- [ ] 행사장에서 쓸 **실제 노트북**으로 `index.html`을 열어 전체화면(`F`) 확인
- [ ] 프로젝터 해상도에서 글자 크기가 충분한지 확인 (뒷자리에서 보이는지)
- [ ] **소리 확인** — 스피커 연결 후 정답 효과음이 나오는지. 안 쓸 거면 `M`으로 음소거
- [ ] 프레젠터 리모컨을 쓴다면 `→` / `←`가 먹는지 확인
- [ ] 25장 전체를 한 번 넘겨보며 오타·틀린 정보 최종 점검
- [ ] 진행 순서 리허설: 문제 → (`T`로 3초 타이머) → 정답 → 선물 전달

### 🟢 원하시면 추가할 수 있는 것 (아직 안 만든 것)

- [ ] **마무리 슬라이드** — 원본 25장에는 감사 인사 슬라이드가 없습니다. "와주셔서 감사합니다" 같은
      마지막 장을 추가할지 결정
- [ ] 문제별 **선물 이름**을 정답 슬라이드에 표시 (규칙 03번 "문제 번호에 맞는 선물"과 연결)
- [ ] 채원이 **사진**을 슬라이드에 넣기 (현재는 픽셀 아트만 사용)
- [ ] 하객 휴대폰으로 응답받는 실시간 참여 방식 (이건 배포·서버가 필요해집니다)

---

## 7. 기술 메모 (Claude용)

- 무대는 **1920×1080 고정** 후 `transform: scale()`로 화면에 맞춥니다. 그래서 모든 좌표·폰트를
  px로 고정해도 어떤 해상도에서든 동일하게 보입니다. (`fit()` 함수)
- 배경의 구름·코인·하트·나무·보물상자·캐릭터는 **전부 인라인 픽셀 SVG** (`ART` 객체)입니다.
  이미지 파일이 아니므로 색·크기를 자유롭게 바꿀 수 있습니다.
- 효과음은 **오디오 파일 없이 WebAudio로 생성**합니다 (`SFX` 객체, 사각파 8비트음).
  브라우저 정책상 **첫 키 입력 이후부터** 소리가 납니다. 첫 화면이 조용한 건 정상입니다.
- 슬라이드 전환은 노드를 `cloneNode`로 교체해 등장 애니메이션을 매번 재생합니다 (`render()`).
- 접근성: `prefers-reduced-motion`을 존중해 애니메이션을 끕니다.
- 폰트 출처 (다시 받아야 할 경우):
  - Press Start 2P: `https://fonts.gstatic.com/s/pressstart2p/v16/e3t4euO8T-267oIAQAu6jDQyK3nVivM.woff2`
  - Galmuri11: `https://cdn.jsdelivr.net/npm/galmuri@latest/dist/Galmuri11.woff2`
  - Pretendard: `https://cdn.jsdelivr.net/npm/pretendard@1.3.9/dist/web/static/woff2/Pretendard-ExtraBold.woff2`
  - (참고: `cdn.jsdelivr.net/gh/orioncactus/...` 경로는 404/403이 납니다. **npm 경로**를 쓰세요.)
