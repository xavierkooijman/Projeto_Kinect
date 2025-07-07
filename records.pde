class Record {
  int score;
  int combo;
  Record(int s, int c) {
    score = s;
    combo = c;
  }
  
  public String toString() {
    return "[" + score + ", " + combo + "]";
  }
}


// saves the best score and best combo
HashMap<String, Record> records;

void loadRecords() {
  records = new HashMap<String, Record>();
  
  // get the best scores and combos from the .txt file
  String[] lines = loadStrings("data/score_records.txt");
  for (String l : lines) {
    
    // split the scores and the combos
    String[] p = splitTokens(l, ":");
    
    // if each line has 3 parts: song name, best score & best combo (correct format)
    if (p.length == 3) {
      
      // saves the info
      records.put(p[0], new Record(int(p[1]), int(p[2])));
    }
  }
}

void updateRecord(String music, int score, int combo) {
  Record track = records.get(music);
  
  // verifies if the new score & combo are better than the best scores & combos saved in the .txt
  // if they are, updates the best score & combo
  int bestScore = max(int(track.score), score);
  int bestCombo = max(int(track.combo), combo);

  
  records.put(music, new Record(bestScore, bestCombo));
  saveRecords();
}

void saveRecords() {
  String[] record = new String[records.size()];
  int i = 0;
  
  for (String track : records.keySet()) {
    Record scores = records.get(track);
    record[i++] = track + ":" + int(scores.score) + ":" + int(scores.combo);
  }
  
  saveStrings("data/score_records.txt", record);
}
