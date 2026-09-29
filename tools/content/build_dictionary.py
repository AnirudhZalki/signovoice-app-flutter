#!/usr/bin/env python3
"""Builds assets/data/sign_dictionary.json.

Only signs with a real, licensed clip get `media`. Everything else is listed
with a meaning so the dictionary/lessons can grow; the app shows an honest
"video not available yet" for those. To add a sign: drop the clip into
assets/videos/, add its filename in MEDIA below (or ship it via the remote
dictionary pack), re-run this script.
"""
import json, os

CATEGORIES = [
    ("alphabet", "abc"), ("numbers", "pin"), ("greetings", "waving_hand"), ("daily", "chat"),
    ("family", "family"), ("food", "restaurant"), ("education", "school"), ("healthcare", "local_hospital"),
    ("travel", "directions_bus"), ("emergency", "emergency"), ("workplace", "work"), ("phrases", "forum"),
]

# id -> (word, meaning, category, {hi:[...], kn:[...]})
E = []
def add(cat, items):
    for it in items:
        word, meaning = it[0], it[1]
        al = it[2] if len(it) > 2 else {}
        E.append((word.lower().replace(' ', '_').replace("'", ''), word, meaning, cat, al))

for ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
    E.append((ch.lower(), ch, f"The letter {ch}, fingerspelled.", "alphabet", {}))

nums = ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"]
for i, n in enumerate(nums):
    E.append((n.lower(), n, f"The number {i}.", "numbers", {}))

add("greetings", [
  ("Hello", "A greeting used when meeting someone.", {"hi": ["नमस्ते"], "kn": ["ನಮಸ್ಕಾರ"]}),
  ("Good morning", "A greeting used in the morning.", {"hi": ["सुप्रभात"], "kn": ["ಶುಭೋದಯ"]}),
  ("Good afternoon", "A greeting used in the afternoon."),
  ("Good evening", "A greeting used in the evening."),
  ("Good night", "Said when parting at night or before sleep.", {"hi": ["शुभ रात्रि"], "kn": ["ಶುಭ ರಾತ್ರಿ"]}),
  ("Goodbye", "Said when leaving.", {"hi": ["अलविदा"], "kn": ["ವಿದಾಯ"]}),
  ("Welcome", "Said to greet someone arriving.", {"hi": ["स्वागत है"], "kn": ["ಸ್ವಾಗತ"]}),
  ("How are you", "Asking about someone's wellbeing."),
  ("Nice to meet you", "Said when meeting someone for the first time."),
  ("Thank you", "Expressing gratitude.", {"hi": ["धन्यवाद", "शुक्रिया"], "kn": ["ಧನ್ಯವಾದ", "ಧನ್ಯವಾದಗಳು"]}),
])
add("daily", [
  ("Yes", "An affirmative answer.", {"hi": ["हाँ"], "kn": ["ಹೌದು"]}),
  ("No", "A negative answer.", {"hi": ["नहीं"], "kn": ["ಇಲ್ಲ"]}),
  ("Please", "A polite request word.", {"hi": ["कृपया"], "kn": ["ದಯವಿಟ್ಟು"]}),
  ("Sorry", "Expressing apology.", {"hi": ["माफ़ कीजिए", "क्षमा"], "kn": ["ಕ್ಷಮಿಸಿ"]}),
  ("Excuse me", "Used to get attention politely or to pass by."),
  ("Help", "Asking for or offering assistance.", {"hi": ["मदद"], "kn": ["ಸಹಾಯ"]}),
  ("Wait", "Asking someone to pause for a moment."),
  ("Stop", "Asking someone to halt.", {"hi": ["रुको"], "kn": ["ನಿಲ್ಲಿ"]}),
  ("Come", "Inviting someone to move toward you.", {"hi": ["आओ"], "kn": ["ಬನ್ನಿ"]}),
  ("Go", "Moving away from the current place."),
  ("Sit", "Taking a seat."),
  ("Understand", "To grasp the meaning of something."),
])
add("family", [
  ("Mother", "Female parent.", {"hi": ["माँ", "माता"], "kn": ["ಅಮ್ಮ", "ತಾಯಿ"]}),
  ("Father", "Male parent.", {"hi": ["पिता", "पापा"], "kn": ["ಅಪ್ಪ", "ತಂದೆ"]}),
  ("Sister", "A female sibling.", {"hi": ["बहन"], "kn": ["ಸಹೋದರಿ"]}),
  ("Brother", "A male sibling.", {"hi": ["भाई"], "kn": ["ಸಹೋದರ"]}),
  ("Grandmother", "The mother of a parent."),
  ("Grandfather", "The father of a parent."),
  ("Son", "A male child."),
  ("Daughter", "A female child."),
  ("Husband", "A married man."),
  ("Wife", "A married woman."),
])
add("food", [
  ("Water", "Clear drinking liquid.", {"hi": ["पानी"], "kn": ["ನೀರು"]}),
  ("Food", "What people eat.", {"hi": ["खाना"], "kn": ["ಆಹಾರ"]}),
  ("Rice", "A staple grain.", {"hi": ["चावल"], "kn": ["ಅನ್ನ", "ಅಕ್ಕಿ"]}),
  ("Bread", "Baked food made from flour."),
  ("Milk", "A white drink from animals.", {"hi": ["दूध"], "kn": ["ಹಾಲು"]}),
  ("Tea", "A hot drink made from tea leaves.", {"hi": ["चाय"], "kn": ["ಚಹಾ"]}),
  ("Fruit", "Sweet food that grows on plants."),
  ("Vegetable", "Edible plant parts eaten as food."),
  ("Hungry", "Needing food."),
  ("Thirsty", "Needing water."),
])
add("education", [
  ("School", "A place where children learn.", {"hi": ["स्कूल"], "kn": ["ಶಾಲೆ"]}),
  ("Teacher", "A person who teaches.", {"hi": ["शिक्षक"], "kn": ["ಶಿಕ್ಷಕ"]}),
  ("Student", "A person who studies."),
  ("Book", "Pages of writing bound together.", {"hi": ["किताब"], "kn": ["ಪುಸ್ತಕ"]}),
  ("Pen", "A tool for writing with ink."),
  ("Learn", "To gain knowledge or skill."),
  ("Read", "To look at and understand written words."),
  ("Write", "To form letters or words on a surface."),
  ("Exam", "A test of knowledge."),
])
add("healthcare", [
  ("Hospital", "A place where sick or injured people receive medical care.", {"hi": ["अस्पताल"], "kn": ["ಆಸ್ಪತ್ರೆ"]}),
  ("Doctor", "A person trained to treat illness.", {"hi": ["डॉक्टर"], "kn": ["ವೈದ್ಯ", "ಡಾಕ್ಟರ್"]}),
  ("Medicine", "A substance used to treat illness.", {"hi": ["दवा", "दवाई"], "kn": ["ಔಷಧ"]}),
  ("Pain", "Physical hurt or discomfort.", {"hi": ["दर्द"], "kn": ["ನೋವು"]}),
  ("Fever", "Higher than normal body temperature.", {"hi": ["बुखार"], "kn": ["ಜ್ವರ"]}),
  ("Ambulance", "A vehicle that carries patients to hospital.", {"hi": ["एम्बुलेंस"], "kn": ["ಆಂಬ್ಯುಲೆನ್ಸ್"]}),
  ("Nurse", "A person who cares for patients."),
  ("Sick", "Not in good health."),
  ("Injection", "Medicine given with a needle."),
  ("Pharmacy", "A shop that sells medicines."),
])
add("travel", [
  ("Bus", "A large road vehicle for many passengers.", {"hi": ["बस"], "kn": ["ಬಸ್"]}),
  ("Train", "A vehicle that runs on rails.", {"hi": ["ट्रेन", "रेल"], "kn": ["ರೈಲು"]}),
  ("Airport", "A place where aircraft take off and land."),
  ("Ticket", "A pass that allows you to travel."),
  ("Road", "A path for vehicles."),
  ("Where", "Used to ask about a place.", {"hi": ["कहाँ"], "kn": ["ಎಲ್ಲಿ"]}),
  ("Station", "A stop where trains or buses arrive."),
  ("Taxi", "A car that carries passengers for a fare."),
  ("Money", "What people use to pay for things.", {"hi": ["पैसा", "पैसे"], "kn": ["ಹಣ"]}),
])
add("emergency", [
  ("Emergency", "A sudden situation needing urgent action.", {"hi": ["आपातकाल"], "kn": ["ತುರ್ತು"]}),
  ("Fire", "Burning that may cause danger.", {"hi": ["आग"], "kn": ["ಬೆಂಕಿ"]}),
  ("Police", "Officers who keep law and order.", {"hi": ["पुलिस"], "kn": ["ಪೊಲೀಸ್"]}),
  ("Danger", "A situation that may cause harm.", {"hi": ["खतरा"], "kn": ["ಅಪಾಯ"]}),
  ("Call for help", "Asking others to get assistance."),
  ("Accident", "An unexpected event causing harm."),
  ("Help me", "A direct request for assistance."),
  ("Lost", "Not knowing where you are."),
])
add("workplace", [
  ("Work", "Activity done as a job."),
  ("Office", "A place where people work at desks."),
  ("Meeting", "A gathering to discuss something."),
  ("Manager", "A person who supervises others."),
  ("Salary", "Regular payment for work."),
  ("Time", "What clocks measure.", {"hi": ["समय"], "kn": ["ಸಮಯ"]}),
  ("Job", "A paid position of employment."),
  ("Interview", "A formal conversation for a job."),
])
add("phrases", [
  ("I love you", "Expressing love and care."),
  ("I don't understand", "Saying you did not understand."),
  ("Please repeat", "Asking someone to say or sign again."),
  ("What is your name", "Asking someone's name."),
  ("My name is", "Introducing yourself."),
  ("Where is the toilet", "Asking for the restroom."),
  ("How much", "Asking about price or quantity."),
  ("I need help", "Saying you need assistance."),
  ("I am deaf", "Telling someone you are Deaf."),
  ("Can you write it down", "Asking someone to write instead."),
  ("Slowly please", "Asking someone to slow down."),
  ("Thank you very much", "Expressing strong gratitude."),
])

# Real clips in assets/videos (recompressed from the legacy repo).
MEDIA = {"hello": "hello.mp4", "a": "a.mp4", "b": "b.mp4", "c": "c.mp4", "thank_you": "thank_you.mp4"}
# Labels of the bundled model (assets/models/labels.json) -> dictionary id.
PRACTICE = {"a": "A", "b": "B", "c": "C", "hello": "Hello", "thank_you": "Thanks", "yes": "Yes", "no": "No",
            "please": "Please", "i_love_you": "I love you"}

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
entries = []
seen = set()
for id_, word, meaning, cat, al in E:
    if id_ in seen:
        raise SystemExit(f"duplicate id {id_}")
    seen.add(id_)
    e = {"id": id_, "word": word, "meaning": meaning, "category": cat}
    if al: e["aliases"] = al
    if id_ in MEDIA:
        p = f"assets/videos/{MEDIA[id_]}"
        assert os.path.exists(os.path.join(root, p)), p
        e["media"] = {"video": p}
    if id_ in PRACTICE: e["practiceLabel"] = PRACTICE[id_]
    entries.append(e)

out = {"version": 1, "categories": [{"id": c, "icon": i} for c, i in CATEGORIES], "entries": entries}
with open(os.path.join(root, 'assets', 'data', 'sign_dictionary.json'), 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=1)
print(len(entries), "entries;", sum(1 for e in entries if 'media' in e), "with media;",
      sum(1 for e in entries if 'practiceLabel' in e), "practiceable")
