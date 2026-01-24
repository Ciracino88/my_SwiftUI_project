// path 라이브러리 사용
const path = require('path');

// node.js 에서 앱을 만들 때 쓰는 라이브러리
const express = require('express');

// 만든 앱을 http 서버에 실어야함.
const http = require('http');

// 서버에 소켓 부착
const { Server } = require('socket.io');

// supabase 라이브러리 호출
const { createClient } = require('@supabase/supabase-js')

// supabase 클라이언트 초기화
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

// express 로 앱 생성
const app = express();

// 만든 앱에 서버 씌우기
const server = http.createServer(app);

// socket.io 서버 초기화, CORS 설정
// CORS: Cross-Origin Resource Sharing (브라우저는 보안 상, 다른 도메인에서 요청이 올 때, 서버의 허락을 받아야만 연결을 허용)
// socket.IO 는 webSocket + polling 을 사용. http 요청 단계인 polling 에서 CORS 검사.
// webSocket - 한 번 연결하면 양방향으로 열려 있는 채널
// polling - 클라이언트가 주기적으로 서버에게 get 요청을 반복 (웹소켓 연결 실패시 사용하는 대안)
const io = new Server(server, {
  cors: {
    origin: "*",          // 개발용. 배포 시 실제 도메인으로 바꾸기
    methods: ["GET", "POST"]
  }
});

// 소켓 연결 이벤트 리스너
io.on('connection', (socket) => {
  console.log('새 사용자 연결됨:', socket.id);

  // 클라이언트에서 'chat' 이벤트 발생
  socket.on('chat', async (message) => {
    // content, username, room_id 를 이용해 message 객체 생성
    // room_id 는 'public' 으로 설정
    const { content, username, room_id = 'public' } = message;

    // 1. supabase 에 메시지 저장
    const { data, error } = await supabase
    .from('message')
    .insert({
      content,
      username,
      room_id: "public",
      user_id: socket.user_id || null
    })
    .select();

    if (error) {
      console.error("DB insert error:", error);
      socket.emit('error', 'failed to save message');
      return;
    }

    // 모든 클라이언트 브로드캐스트(변경사항을 모든 유저 화면에 업데이트)
    io.emit('chat', data[0]);
  });

  socket.on('disconnect', () => {
    console.log('사용자 연결 종료');
  });
});

// 포트 환경변수 사용
// Render 에서 생성해준 랜덤 포트번호 또는 로컬 3000번만 허용
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Socket.IO 서버 실행 중`);
});

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'))
});

// 메시지 로드 엔드포인트
app.get('/past-message', async (req, res) => {
  console.log("메시지 로드");
  try {
    const { data, error } = await supabase
    .from('message')
    .select('content, username, created_at')
    .order('created_at', { ascending: true })
    .limit(50) // 50개까지만 로드

  if (error) throw error;
  
  res.json(data || []);
  } catch (err) {
    console.log("메시지 로드 실패: ", err);
    res.status(500).json({ error: "서버 오류" });
  }
});