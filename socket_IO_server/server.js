// server.js (Node.js)
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",          // 개발용, 배포 시 실제 도메인으로 제한
    methods: ["GET", "POST"]
  }
});

io.on('connection', (socket) => {
  console.log('새 사용자 연결됨:', socket.id);

  // 클라이언트에서 'chat' 이벤트 보내면
  socket.on('chat', (message) => {
    console.log('수신:', message);
    // 모든 클라이언트에게 브로드캐스트 (또는 socket.emit으로 특정인에게)
    io.emit('chat', message);  
  });

  socket.on('disconnect', () => {
    console.log('사용자 연결 종료');
  });
});

// 포트 환경변수 사용
// Render 에서 생성해준 랜덤 포트번호 또는 로컬 3000번만 허용
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Socket.IO 서버 실행 중 → http://localhost:${PORT}`);
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// 무료 티어 sleep 방지용
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});