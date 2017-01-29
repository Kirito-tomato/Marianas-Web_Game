import processing.sound.*;

UI ui = new UI();
PImage icon;
JSONObject settings, github;

void settings() {
  //Load Github File
  if (doesFileExist("cfg/github.json", false)) {
    github = loadJSONObject("cfg/github.json");
  } else {
    github = loadJSONObject("https://raw.githubusercontent.com/midymyth/Marianas-Web_Game/master/game/data/cfg/github.json");
    saveJSONObject(github, "data/cfg/github.json");
  }
  //Load Settings File
  doesFileExist("cfg/settings.json", true);
  settings = loadJSONObject("cfg/settings.json");
  
  //Window Settings
  doesFileExist("assets/icons/logo_small.png", true);
  PJOGL.setIcon("assets/icons/logo_small.png");
  if (settings.getJSONObject("fullscreen").getBoolean("enabled")) {
    fullScreen(P3D, settings.getJSONObject("fullscreen").getInt("monitor"));
  } else {
    size(settings.getJSONObject("windowed").getInt("width"), settings.getJSONObject("windowed").getInt("height"), P3D);
  }
}

void setup() {
  frameRate(30);
  surface.setTitle("Marianas Web");
  surface.setLocation(displayWidth/2 - width / 2, displayHeight/2 - height / 2);
  doesFileExist("levels/main_menu.json", true);
  ui.load(loadJSONObject("levels/main_menu.json"));
}