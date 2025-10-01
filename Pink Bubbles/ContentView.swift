import SwiftUI

// App Entry Point
@main
struct PinkBubblesApp: App {
    @StateObject private var appData = AppData()

    var body: some Scene {
        WindowGroup {
            ContentView(appData: appData)
        }
    }
}

// Content View
struct ContentView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        TabView {
            HomeView(appData: appData)
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
            NotesView(appData: appData)
                .tabItem {
                    VStack {
                        Image(systemName: "pencil")
                        Text("Notes")
                    }
                }
            CalendarView(appData: appData)
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                }
            RemindersView(appData: appData)
                .tabItem {
                    VStack {
                        Image(systemName: "bell")
                        Text("Reminders")
                    }
                }
            ProfileView(appData: appData)
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                }
        }
        .accentColor(Color(hex: "#FF4FBF"))
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
            UITabBar.appearance().barTintColor = UIColor(Color(hex: "#301A4B"))
            UITabBar.appearance().isTranslucent = true
        }
    }
}

// Models
struct Note: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var content: String
    var isCompleted: Bool = false
}

struct Reminder: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var dueDate: Date
    var isCompleted: Bool = false
}

struct Event: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var date: Date
}

struct Achievement: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var isUnlocked: Bool
}

struct SelectedDate: Identifiable {
    let id = UUID()
    let date: Date
}

// Data Store
class AppData: ObservableObject {
    @Published var notes: [Note] = [
        Note(title: "Welcome to Bubble Life", content: "Start your bubbly journey!"),
        Note(title: "Buy groceries", content: "Milk, eggs, bread"),
        Note(title: "Work tasks", content: "Finish report")
    ]
    @Published var reminders: [Reminder] = [
        Reminder(title: "Call doctor", dueDate: Date(timeIntervalSinceNow: 86400 * 2), isCompleted: false),
        Reminder(title: "Buy groceries", dueDate: Date(timeIntervalSinceNow: 86400 * 2), isCompleted: false),
        Reminder(title: "Call mom", dueDate: Date(timeIntervalSinceNow: -86400), isCompleted: true)
    ]
    @Published var events: [Event] = []
    @Published var achievements: [Achievement] = [
        Achievement(title: "First Note", description: "Created your first bubble note", isUnlocked: true),
        Achievement(title: "Task Master", description: "Completed 10 reminders", isUnlocked: false),
        Achievement(title: "Consistent", description: "7-day activity streak", isUnlocked: true),
        Achievement(title: "Organizer", description: "Created 5 different types of bubbles", isUnlocked: true)
    ]
    @Published var daysActive: Int = 635
    @Published var currentStreak: Int = 12
    @Published var weeklyCompletion: [Double] = [6, 55, 4, 15, 88, 75, 6]
    
    func completedRemindersCount() -> Int {
        reminders.filter { $0.isCompleted }.count
    }
    
    func totalNotes() -> Int {
        notes.count
    }
    
    func completionRate() -> Double {
        let total = reminders.count
        return total > 0 ? Double(completedRemindersCount()) / Double(total) * 100 : 0
    }
    
    func todaysTasks() -> [AnyHashable] {
        let today = Date()
        let calendar = Calendar.current
        let todaysReminders = reminders.filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
        let todaysEvents = events.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let todaysNotes = notes.filter { !$0.isCompleted }
        let allTasks: [AnyHashable] = todaysNotes.map { $0 as AnyHashable } + todaysReminders.map { $0 as AnyHashable } + todaysEvents.map { $0 as AnyHashable }
        return allTasks
    }
    
    func completedTodaysTasks() -> [AnyHashable] {
        let today = Date()
        let calendar = Calendar.current
        let completedReminders = reminders.filter { $0.isCompleted && calendar.isDate($0.dueDate, inSameDayAs: today) }
        let completedNotes = notes.filter { $0.isCompleted }
        let allCompleted: [AnyHashable] = completedNotes.map { $0 as AnyHashable } + completedReminders.map { $0 as AnyHashable }
        return allCompleted
    }
}

// Custom Bubble View
struct BubbleView: View {
    let size: CGFloat
    let icon: String?
    let label: String?
    let color: Color
    let onTap: (() -> Void)?
    
    init(size: CGFloat = 60, icon: String? = nil, label: String? = nil, color: Color = Color(hex: "#FF4FBF"), onTap: (() -> Void)? = nil) {
        self.size = size
        self.icon = icon
        self.label = label
        self.color = color
        self.onTap = onTap
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [color.opacity(0.9), Color(hex: "#B84FFF").opacity(0.8)]), center: .center, startRadius: 0, endRadius: size / 2))
                    .frame(width: size, height: size)
                    .shadow(color: Color(hex: "#4FFFE0").opacity(0.5), radius: 8, x: 0, y: 0)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: size / 2, height: size / 2)
                            .offset(x: -size / 4, y: -size / 4)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: size / 2.5, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            if let label = label {
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: size * 1.5)
                    .shadow(color: .black.opacity(0.2), radius: 2)
            }
        }
        .onTapGesture {
            onTap?()
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2))
    }
}

// Background with particles and falling bubbles
struct BubbleBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#301A4B"), Color(hex: "#4A2A6E")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            // Particles
            ForEach(0..<30) { _ in
                Circle()
                    .fill(Color(hex: "#4FFFE0").opacity(0.15))
                    .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                    .animation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true))
            }
            // Falling bubbles
            ForEach(0..<8) { _ in
                BubbleView(size: CGFloat.random(in: 25...50), color: Color(hex: "#FF4FBF").opacity(0.7))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: -50)
                    .animation(.linear(duration: Double.random(in: 6...12)).repeatForever(autoreverses: false))
                    .offset(y: UIScreen.main.bounds.height + 50)
            }
        }
    }
}

// Home View
struct HomeView: View {
    @ObservedObject var appData: AppData
    @State private var showCompleted = false
    @State private var showingAddNote = false
    @State private var showingAddReminder = false
    @State private var showingAddEvent = false
    @State private var showingStats = false
    
    var todaysDate: String {
        "Today, Saturday, September 27"
    }
    
    var subtitle: String {
        "You have 0 events and 0 reminders today"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                BubbleBackground()
                VStack(spacing: 20) {
                    VStack {
                        Text(todaysDate)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.2), radius: 2)
                    }
                    .padding(.top, 20)
                    
                    ScrollView {
                        ForEach(appData.todaysTasks(), id: \.self) { task in
                            if let note = task as? Note {
                                TaskItemView(title: note.title, detail: "", icon: "✏️", isCompleted: note.isCompleted) {
                                    if let index = appData.notes.firstIndex(where: { $0.id == note.id }) {
                                        appData.notes[index].isCompleted.toggle()
                                    }
                                }
                            } else if let reminder = task as? Reminder {
                                TaskItemView(title: reminder.title, detail: formatter.string(from: reminder.dueDate), icon: "🔔", isCompleted: reminder.isCompleted) {
                                    if let index = appData.reminders.firstIndex(where: { $0.id == reminder.id }) {
                                        appData.reminders[index].isCompleted.toggle()
                                    }
                                }
                            } else if let event = task as? Event {
                                TaskItemView(title: event.title, detail: formatter.string(from: event.date), icon: "📅", isCompleted: false) {}
                            }
                        }
                    }
                    
                    Button(action: {
                        showCompleted.toggle()
                    }) {
                        Text("\(appData.completedTodaysTasks().count)/\(appData.todaysTasks().count + appData.completedTodaysTasks().count) tasks done today - \(Int(appData.completionRate()))%")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color(hex: "#B84FFF").opacity(0.6)))
                            .shadow(color: Color(hex: "#4FFFE0").opacity(0.4), radius: 5)
                    }
                    if showCompleted {
                        ScrollView {
                            ForEach(appData.completedTodaysTasks(), id: \.self) { task in
                                if let note = task as? Note {
                                    TaskItemView(title: note.title, detail: "", icon: "✏️", isCompleted: true) {}
                                        .opacity(0.7)
                                } else if let reminder = task as? Reminder {
                                    TaskItemView(title: reminder.title, detail: "Was due: \(formatter.string(from: reminder.dueDate))", icon: "🔔", isCompleted: true) {}
                                        .opacity(0.7)
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                    
                    HStack(spacing: 30) {
                        BubbleView(size: 40, icon: "✏️", label: "Add Note") { showingAddNote = true }
                        BubbleView(size: 40, icon: "🔔", label: "Add Reminder") { showingAddReminder = true }
                        BubbleView(size: 40, icon: "📅", label: "Add Event") { showingAddEvent = true }
                        BubbleView(size: 40, icon: "📊", label: "Stats") { showingStats = true }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .sheet(isPresented: $showingAddNote) { AddNoteView(appData: appData) }
            .sheet(isPresented: $showingAddReminder) { AddReminderView(appData: appData) }
            .sheet(isPresented: $showingAddEvent) { AddEventView(appData: appData) }
        }
        .fullScreenCover(isPresented: $showingStats) { StatsView(appData: appData) }
    }
    
    private var formatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy"
        return fmt
    }
}

// Task Item View
struct TaskItemView: View {
    let title: String
    let detail: String
    let icon: String
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            BubbleView(size: 40, icon: icon)
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            Spacer()
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#4FFFE0"))
                    .font(.system(size: 24))
            } else {
                Button(action: onTap) {
                    Image(systemName: "circle")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "#B84FFF").opacity(0.4)))
        .shadow(color: Color(hex: "#4FFFE0").opacity(0.3), radius: 5)
    }
}

// Notes View
struct NotesView: View {
    @ObservedObject var appData: AppData
    @State private var showingAdd = false
    @State private var selectedNote: Note? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                BubbleBackground()
                VStack {
                    Text("Bubble Notes")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                    if appData.notes.isEmpty {
                        Text("You don’t have any notes yet — Tap + to add your first bubble.")
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                                ForEach(appData.notes) { note in
                                    BubbleView(size: 80, label: note.title.count > 15 ? String(note.title.prefix(15)) + "..." : note.title) {
                                        selectedNote = note
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    BubbleView(size: 50, icon: "+", label: nil) { showingAdd = true }
                        .foregroundColor(Color(hex: "#4FFFE0"))
                }
                .padding()
            }
            .sheet(isPresented: $showingAdd) { AddNoteView(appData: appData) }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note, appData: appData)
            }
        }
    }
}

// Note Detail View
struct NoteDetailView: View {
    let note: Note
    @ObservedObject var appData: AppData
    @Environment(\.presentationMode) var presentationMode
    @State private var editedTitle = ""
    @State private var editedContent = ""
    
    init(note: Note, appData: AppData) {
        self.note = note
        self.appData = appData
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        ZStack {
            BubbleBackground()
            VStack {
                TextField("Title", text: $editedTitle)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                TextEditor(text: $editedContent)
                    .foregroundColor(.white.opacity(0.9))
                    .padding()
                HStack {
                    Button("Save") {
                        if let index = appData.notes.firstIndex(where: { $0.id == note.id }) {
                            appData.notes[index].title = editedTitle
                            appData.notes[index].content = editedContent
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color(hex: "#4FFFE0"))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                    Button("Delete") {
                        if let index = appData.notes.firstIndex(where: { $0.id == note.id }) {
                            appData.notes.remove(at: index)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// Add Note View
struct AddNoteView: View {
    @ObservedObject var appData: AppData
    @State private var title = ""
    @State private var content = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            BubbleBackground()
            VStack {
                Text("Create New Note")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                TextField("Note title...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(hex: "#FF4FBF").opacity(0.3))
                    .foregroundColor(.white)
                TextEditor(text: $content)
                    .frame(height: 200)
                    .background(Color(hex: "#B84FFF").opacity(0.3))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                Button("Create Note") {
                    appData.notes.append(Note(title: title, content: content))
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF4FBF"), Color(hex: "#B84FFF")]), startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color(hex: "#4FFFE0").opacity(0.4), radius: 5)
            }
            .padding()
        }
    }
}

// Calendar View
struct CalendarView: View {
    @ObservedObject var appData: AppData
    @State private var currentMonth = Date()
    @State private var showingAdd = false
    @State private var selectedDate: SelectedDate? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                BubbleBackground()
                VStack {
                    Text("Bubble Calendar")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                    Text(monthYearString)
                        .foregroundColor(.white.opacity(0.9))
                    CalendarGridView(currentMonth: $currentMonth, events: appData.events, selectedDate: $selectedDate)
                    if appData.events.isEmpty {
                        Text("No events today — Tap + to add your first bubble event.")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    BubbleView(size: 50, icon: "+", label: nil) { showingAdd = true }
                        .foregroundColor(Color(hex: "#4FFFE0"))
                }
                .padding()
            }
            .sheet(isPresented: $showingAdd) { AddEventView(appData: appData) }
            .sheet(item: $selectedDate) { sel in
                EventListView(date: sel.date, appData: appData)
            }
        }
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
}

// Calendar Grid
struct CalendarGridView: View {
    @Binding var currentMonth: Date
    let events: [Event]
    @Binding var selectedDate: SelectedDate?
    
    var days: [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in range.lowerBound..<range.upperBound {
            if let date = calendar.date(bySetting: .day, value: day, of: currentMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    func eventsForDay(_ day: Date) -> [Event] {
        events.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                Text(day)
                    .foregroundColor(.white.opacity(0.7))
                    .fontWeight(.bold)
            }
            ForEach(days, id: \.self) { date in
                let isToday = Calendar.current.isDateInToday(date)
                let isPast = date < Date()
                let dayString = String(Calendar.current.component(.day, from: date))
                let eventCount = eventsForDay(date).count
                BubbleView(size: 40, icon: dayString, label: nil) {
                    selectedDate = SelectedDate(date: date)
                }
                .opacity(isPast && !isToday ? 0.5 : 1.0)
                .overlay(isToday ? Circle().stroke(Color(hex: "#FF4FBF"), lineWidth: 3) : nil)
                .overlay(alignment: .bottomTrailing) {
                    if eventCount > 0 {
                        BubbleView(size: 15, icon: "\(eventCount)", label: nil, color: Color(hex: "#4FFFE0"))
                    }
                }
            }
        }
    }
}

// Event List View
struct EventListView: View {
    let date: Date
    @ObservedObject var appData: AppData
    @State private var showingAddEvent = false
    
    var formatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        return fmt
    }
    
    var eventsForDay: [Event] {
        appData.events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    var body: some View {
        ZStack {
            BubbleBackground()
            VStack {
                Text(formatter.string(from: date))
                    .font(.title2.bold())
                    .foregroundColor(.white)
                if eventsForDay.isEmpty {
                    Text("No events on this day")
                        .foregroundColor(.white.opacity(0.9))
                } else {
                    ForEach(eventsForDay) { event in
                        Text(event.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#B84FFF").opacity(0.4))
                            .cornerRadius(10)
                    }
                }
                BubbleView(size: 50, icon: "+", label: "Add Event") { showingAddEvent = true }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddEvent) { AddEventView(appData: appData, preselectedDate: date) }
    }
}

// Modified Add Event View with preselected date
struct AddEventView: View {
    @ObservedObject var appData: AppData
    @State private var title = ""
    @State private var date: Date
    @Environment(\.presentationMode) var presentationMode
    
    init(appData: AppData, preselectedDate: Date? = nil) {
        self.appData = appData
        _date = State(initialValue: preselectedDate ?? Date())
    }
    
    var body: some View {
        ZStack {
            BubbleBackground()
            VStack {
                Text("Create New Event")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                TextField("Event title...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(hex: "#FF4FBF").opacity(0.3))
                    .foregroundColor(.white)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .foregroundColor(.white)
                    .accentColor(Color(hex: "#FF4FBF"))
                Button("Create Event") {
                    appData.events.append(Event(title: title, date: date))
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF4FBF"), Color(hex: "#B84FFF")]), startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color(hex: "#4FFFE0").opacity(0.4), radius: 5)
            }
            .padding()
        }
    }
}

// Reminders View
struct RemindersView: View {
    @ObservedObject var appData: AppData
    @State private var showingAdd = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BubbleBackground()
                VStack {
                    Text("Bubble Reminders")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                    Text("Active")
                        .foregroundColor(.white.opacity(0.9))
                    ForEach(appData.reminders.filter { !$0.isCompleted }) { reminder in
                        ReminderItemView(reminder: reminder, onComplete: {
                            if let index = appData.reminders.firstIndex(where: { $0.id == reminder.id }) {
                                appData.reminders[index].isCompleted.toggle()
                            }
                        })
                    }
                    Text("Completed")
                        .foregroundColor(.white.opacity(0.9))
                    ForEach(appData.reminders.filter { $0.isCompleted }) { reminder in
                        ReminderItemView(reminder: reminder, isCompleted: true, onComplete: {})
                            .opacity(0.7)
                    }
                    if appData.reminders.isEmpty {
                        Text("No reminders yet — Tap + to create.")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    BubbleView(size: 50, icon: "+", label: nil) { showingAdd = true }
                        .foregroundColor(Color(hex: "#4FFFE0"))
                }
                .padding()
            }
            .sheet(isPresented: $showingAdd) { AddReminderView(appData: appData) }
        }
    }
}

struct ReminderItemView: View {
    let reminder: Reminder
    let isCompleted: Bool
    let onComplete: () -> Void
    
    init(reminder: Reminder, isCompleted: Bool = false, onComplete: @escaping () -> Void) {
        self.reminder = reminder
        self.isCompleted = isCompleted
        self.onComplete = onComplete
    }
    
    var body: some View {
        HStack {
            BubbleView(size: 40, icon: "🔔")
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                Text("Due: \(formatter.string(from: reminder.dueDate))")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#FF4FBF").opacity(0.9))
            }
            Spacer()
            Button(action: onComplete) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? Color(hex: "#4FFFE0") : .white)
                    .font(.system(size: 24))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "#B84FFF").opacity(0.4)))
        .shadow(color: Color(hex: "#4FFFE0").opacity(0.3), radius: 5)
    }
    
    private var formatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        return fmt
    }
}

// Add Reminder View
struct AddReminderView: View {
    @ObservedObject var appData: AppData
    @State private var title = ""
    @State private var dueDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            BubbleBackground()
            VStack {
                Text("Create New Reminder")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                TextField("Reminder title...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(hex: "#FF4FBF").opacity(0.3))
                    .foregroundColor(.white)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    .foregroundColor(.white)
                    .accentColor(Color(hex: "#FF4FBF"))
                Button("Create Reminder") {
                    appData.reminders.append(Reminder(title: title, dueDate: dueDate))
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF4FBF"), Color(hex: "#B84FFF")]), startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color(hex: "#4FFFE0").opacity(0.4), radius: 5)
            }
            .padding()
        }
    }
}

// Stats View
struct StatsView: View {
    @ObservedObject var appData: AppData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            BubbleBackground()
            VStack(spacing: 20) {
                Text("Bubble Statistics")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                HStack(spacing: 20) {
                    BubbleView(size: 70, icon: "\(appData.totalNotes())", label: "Total Notes", color: Color(hex: "#FF6B9A"))
                    BubbleView(size: 70, icon: "\(appData.completedRemindersCount())", label: "Reminders Done", color: Color(hex: "#4ECDC4"))
                    BubbleView(size: 70, icon: "\(Int(appData.completionRate()))%", label: "Completion", color: Color(hex: "#45B7D1"))
                }
                .padding(.horizontal)
                
                Text("Weekly Progress")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 2)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<7) { i in
                            VStack {
                                BubbleView(size: 40, icon: "\(Int(appData.weeklyCompletion[i]))%", color: Color(hex: i == 4 ? "#FF4FBF" : "#B84FFF"))
                                Text(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i])
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Text("Achievements")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 2)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(appData.achievements) { ach in
                        VStack {
                            Image(systemName: ach.isUnlocked ? "trophy.fill" : "trophy")
                                .foregroundColor(ach.isUnlocked ? Color(hex: "#FF4FBF") : .gray)
                                .font(.system(size: 30))
                            Text(ach.title)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                            Text(ach.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(width: 140, height: 120)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(hex: "#B84FFF").opacity(0.5)))
                        .shadow(color: Color(hex: "#4FFFE0").opacity(0.3), radius: 5)
                    }
                }
                .padding(.horizontal)
                
                Text("You popped 4 bubbles this week! 🎉")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color(hex: "#FF4FBF").opacity(0.7)))
                    .shadow(color: Color(hex: "#4FFFE0").opacity(0.4), radius: 5)
            }
            .padding(.vertical, 20)
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.headline)
            .padding()
            .background(Color(hex: "#FF6B9A"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color(hex: "#4FFFE0").opacity(0.4), radius: 5)
            .position(x: UIScreen.main.bounds.width - 60, y: 60)
        }
    }
}

// Profile View
struct ProfileView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        NavigationView {
            ZStack {
                BubbleBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Profile")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                        BubbleView(size: 100, icon: "👤", label: nil)
                        Text("Bubble Explorer")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Living life one bubble at a time ⭐")
                            .foregroundColor(.white.opacity(0.9))
                        Text("Member since January 2024")
                            .foregroundColor(.white.opacity(0.7))
                        HStack {
                            BubbleView(size: 60, icon: "\(appData.totalNotes())", label: "Total Notes")
                            BubbleView(size: 60, icon: "\(appData.completedRemindersCount())", label: "Completed Tasks")
                        }
                        HStack {
                            BubbleView(size: 60, icon: "\(appData.daysActive)", label: "Days Active")
                            BubbleView(size: 60, icon: "\(appData.currentStreak) days", label: "Current Streak")
                        }
                        Text("Achievements")
                            .foregroundColor(.white.opacity(0.9))
                        ForEach(appData.achievements) { ach in
                            HStack {
                                Image(systemName: ach.isUnlocked ? "star.fill" : "star")
                                    .foregroundColor(Color(hex: "#4FFFE0"))
                                    .font(.system(size: 20))
                                Text(ach.title)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Text(ach.description)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#B84FFF").opacity(0.4)))
                            .shadow(color: Color(hex: "#4FFFE0").opacity(0.3), radius: 5)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appData: AppData())
    }
}
