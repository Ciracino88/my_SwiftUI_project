import SwiftUI
import Foundation
import SwiftData

// 성경 모델 작성하기
struct Verse: Identifiable {
    var id = UUID()
    let bookAbbrev: String // 책 약어: 창세기 -> 창
    let bookName: String
    let chapter: Int // 장
    let verse: Int // 절
    let text: String // 내용
}

struct Chapter: Identifiable {
    var id: Int { index } // 장 번호를 id로 사용
    let index: Int
    var verses: [Verse]
    
    mutating func append(_ verse: Verse) {
        verses.append(verse)
        verses.sort { $0.verse < $1.verse }
    }
}

struct Book: Identifiable {
    let id: Int
    let abbrev: String
    let name: String
    var chapters: [Chapter]
}

// 좋아하는 구절을 북마크
@Model
class Bookmark {
    var id: UUID
    var verseID: UUID
    var createdAt: Date
    
    init(id: UUID = UUID(), verseID: UUID) {
        self.id = id
        self.verseID = verseID
        self.createdAt = Date()
    }
}

typealias Bible = [Book] // 타입 별명: [Book] 대신 앞으로 Bible 로 쓰겠다.

class BibleLoader {
    
    static let bookOrder: [String] = [
        "창", "출", "레", "민", "신",
        "수", "삿", "룻", "삼상", "삼하",
        "왕상", "왕하", "대상", "대하",
        "스", "느", "에", "욥", "시",
        "잠", "전", "아", "사", "렘",
        "애", "겔", "단", "호", "욜",
        "암", "옵", "욘", "미", "나",
        "합", "습", "학", "슥", "말",
        
        "마", "막", "눅", "요", "행",
        "롬", "고전", "고후", "갈", "엡",
        "빌", "골", "살전", "살후",
        "딤전", "딤후", "딛", "몬",
        "히", "약", "벧전", "벧후",
        "요일", "요이", "요삼", "유", "계"
    ]
    
    static let bookNames: [String: String] = [
        "창": "창세기", "출": "출애굽기", "레": "레위기", "민": "민수기", "신": "신명기",
        "수": "여호수아", "삿": "사사기", "룻": "룻기", "삼상": "사무엘상", "삼하": "사무엘하",
        "왕상": "열왕기상", "왕하": "열왕기하", "대상": "역대상", "대하": "역대하",
        "스": "에스라", "느": "느헤미야", "에": "에스더", "욥": "욥기", "시": "시편",
        "잠": "잠언", "전": "전도서", "아": "아가", "사": "이사야", "렘": "예레미야",
        "애": "예레미야애가", "겔": "에스겔", "단": "다니엘", "호": "호세아", "욜": "요엘",
        "암": "아모스", "옵": "오바댜", "욘": "요나", "미": "미가", "나": "나훔",
        "합": "하박국", "습": "스바냐", "학": "학개", "슥": "스가랴", "말": "말라기",
        
        "마": "마태복음", "막": "마가복음", "눅": "누가복음", "요": "요한복음", "행": "사도행전",
        "롬": "로마서", "고전": "고린도전서", "고후": "고린도후서", "갈": "갈라디아서", "엡": "에베소서",
        "빌": "빌립보서", "골": "골로새서", "살전": "데살로니가전서", "살후": "데살로니가후서",
        "딤전": "디모데전서", "딤후": "디모데후서", "딛": "디도서", "몬": "빌레몬서",
        "히": "히브리서", "약": "야고보서", "벧전": "베드로전서", "벧후": "베드로후서",
        "요일": "요한일서", "요이": "요한이서", "요삼": "요한삼서", "유": "유다서", "계": "요한계시록"
    ]
    
    static func loadBible() -> Bible {
        let verses: [Verse] = loadVerses()
        
        // 책별 그룹화
        let grouped = Dictionary(grouping: verses) { $0.bookAbbrev }
        
        var books: [Book] = []
        var bookIndex = 0
        
        for abbrev in bookOrder {
            guard let name = bookNames[abbrev],
                  let verses = grouped[abbrev] else { continue }
            
            // 장별 그룹화
            let chapterGroups = Dictionary(grouping: verses) { $0.chapter }
            let chapters = chapterGroups.keys.sorted().map { index in
                let sortedVerses = chapterGroups[index]!.sorted { $0.verse < $1.verse }
                return Chapter(index: index, verses: sortedVerses)
            }
            
            let book = Book(id: bookIndex, abbrev: abbrev, name: name, chapters: chapters)
            books.append(book)
            bookIndex += 1
        }
        
        print("\(books.count)권 로드")
        return books
    }
    
    static func loadVerses() -> [Verse] {
        guard let url = Bundle.main.url(forResource: "bible", withExtension: "json") else {
            fatalError("JSON 파일을 찾을 수 없습니다.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let raw = try JSONDecoder().decode([String: String].self, from: data)
            
            let verses: [Verse] = raw.compactMap { key, text in
                let parts = key.split(separator: ":")
                
                guard parts.count == 2,
                      let verseString = parts.last,
                      let verseIndex = Int(verseString)
                else { return nil }
                
                let front = String(parts[0])
                var abbrev = ""
                var chapter = ""
                
                for f in front {
                    if f.isNumber {
                        chapter.append(f)
                    } else {
                        abbrev.append(f)
                    }
                }
                
                guard !abbrev.isEmpty,
                      !chapter.isEmpty,
                      let chapterIndex = Int(chapter),
                      let name = bookNames[abbrev]
                else { return nil }
                
                return Verse(bookAbbrev: abbrev, bookName: name, chapter: chapterIndex, verse: verseIndex, text: text)
            }
            
            return verses
        } catch {
            fatalError("JSON 로드 및 파싱 오류")
        }
    }
}

struct BibieView: View {
    @State private var bible: Bible = []
    @State private var selectedBook: Book?
    @State private var showBookmarkFullScreen = false
    
    var body: some View {
        if bible.isEmpty {
            ProgressView("성경을 불러오고 있습니다...")
                .task {
                    bible = BibleLoader.loadBible()
                }
        } else {
            if let book = selectedBook {
                List(book.chapters) { chapter in
                    NavigationLink(destination: BibleChapterView(name: book.name, chapter: chapter)) {
                        Text("\(chapter.index)장")
                    }
                }
                .navigationTitle("\(book.name)")
            } else {
                List(bible) { book in
                    NavigationLink(destination: BibleBookView(book: book)) {
                        Text(book.name)
                    }
                }
                .navigationTitle("성경 \(bible.count)권")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showBookmarkFullScreen = true
                        } label: {
                            Image(systemName: "bookmark")
                        }
                    }
                }
                .fullScreenCover(isPresented: $showBookmarkFullScreen) {
                    BibleBookmarkView()
                }
            }
        }
        
    }
}

struct BibleBookmarkView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark] // @Query 프로퍼티만으로 해당 데이터가 불러와짐
    
    @State private var isLoading = false
    @State private var bookmarkedVerses: [Verse] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                    Text("북마크 로드 중...")
                } else {
                    ForEach(bookmarkedVerses) { verse in
                        BibleSwipeableVerseCard(verse: verse)
                    }
                }
            }
        }
        .task {
            isLoading = true
            let verses = BibleLoader.loadVerses()
            let bookmarkedVerseIDs = Set(bookmarks.map { $0.verseID })
            
            bookmarkedVerses = verses.filter { verse in
                bookmarkedVerseIDs.contains(verse.id)
            }
            isLoading = false
        }
    }
}

struct BibleBookView: View {
    @State var showInfoSheet = false
    
    let book: Book
    var body: some View {
        List(book.chapters) { chapter in
            NavigationLink(destination: BibleChapterView(name: book.name, chapter: chapter)) {
                Text("\(chapter.index)장")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showInfoSheet.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            BibleBookInfoSheet(book: book)
        }
    }
}

struct BibleBookInfoSheet: View {
    let book: Book
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("\(book.name)는 \(calculateVerseCount())개의 절로 이루어져 있습니다.")
                    .font(.system(size: 18))
                    .fontWeight(.light)
            }
            .padding()
        }
    }
    
    func calculateVerseCount() -> Int {
        var result = 0
        for c in book.chapters {
            result += c.verses.count
        }
        
        return result
    }
}

struct BibleChapterView: View {
    let name: String
    let chapter: Chapter
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(chapter.verses) { verse in
                    BibleVerseCard(verse: verse)
                }
            }
        }
        .navigationTitle("\(name) \(chapter.index)장")
    }
}

struct BibleSwipeableVerseCard: View {
    let verse: Verse
    
    @State private var offset: CGFloat = 0
    @State private var isSwipe = false
    
    private let fullSwipeValue: CGFloat = 80 // 최대 스와이프 값
    
    var body: some View {
        // 1. zstack
        ZStack {
            // 2. 스와이프 버튼 나열
            HStack(spacing: 0) {
                Spacer()
                actionButton(systemName: "bookmark", color: .blue) {
                    
                }
            }
            .padding(.trailing, 8)
            .opacity(Double(max(0, -offset / fullSwipeValue))) // 스와이프한 정도에 따라 천천히 드러나게 하기
            
            // 3. 카드로 덮기
            BibleVerseCard(verse: verse)
                .offset(x: offset)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            // 4. 스와이프 기능 적용
                            let horizontal = value.translation.width
                            if horizontal <= 0 {
                                offset = max(horizontal, -fullSwipeValue)
                            } else {
                                offset = 0
                            }
                            
                            // 끝까지 스와이프 하였는지 판단
                            isSwipe = abs(offset) >= fullSwipeValue
                        }
                        .onEnded { value in
                            // 5. 애니메이션 적용
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if abs(value.translation.width) >= fullSwipeValue && value.translation.width < 0 {
                                    // 끝까지 스와이프 했을 때만 애니매이션을 실행
                                    offset = -fullSwipeValue
                                    isSwipe = true
                                } else {
                                    offset = 0
                                    isSwipe = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    // 카드 탭하면 스와이프 초기화
                    withAnimation {
                        offset = 0
                        isSwipe = false
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        }
    }
    
    private func actionButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
            withAnimation(.spring()) {
                offset = 0
                isSwipe = false
            }
        } label: {
            Image(systemName: isSwipe ? "\(systemName).fill" : systemName)
                .foregroundStyle(color)
                .frame(width: 60, height: 80)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 끝까지 스와이프 했을 때, 로직 수행
    private func executeAction(for translation: CGFloat) {
        if translation < 0 {
            
        }
    }
    
}

struct BibleVerseCard: View {
    let verse: Verse
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(verse.verse)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.accentColor))
                .padding(.top, 4)
            
            Text(verse.text)
                .font(.body)
                .lineLimit(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}
