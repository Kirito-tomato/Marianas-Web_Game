PFont fonts[];
float lastMouseRX, lastMouseRY, mouseRX, mouseRY = -1;

void loadFonts() {
  JSONArray fontsArray = loadJSONArray("cfg/fonts.json");
  fonts = new PFont[fontsArray.size()];
  for (int i = 0; i < fontsArray.size(); i++) {
    fonts[i] = createFont(fontsArray.getJSONObject(i).getString("file"), fontsArray.getJSONObject(i).getInt("size") * width / 1280);
  }
}

void draw() { 
  mouseRX = mouseX * 1280 / width; mouseRY = mouseY * 720 / height; //Beginning of function
  
  if (ui.getElementIdByPosition(mouseRX, mouseRY) >= 0 && ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").getString("background") != "active" && ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).hasKey("colors")) {
    ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").setString("background", "highlight");
  }
  if (ui.getElementIdByPosition(mouseRX, mouseRY) == -1 && lastMouseRX != -1 && lastMouseRY != -1 && ui.getElementIdByPosition(lastMouseRX,lastMouseRY) >= 0 && ui.ElementsData.getJSONObject(ui.getElementIdByPosition(lastMouseRX,lastMouseRY)).hasKey("colors")) {
    ui.ElementsData.getJSONObject(ui.getElementIdByPosition(lastMouseRX,lastMouseRY)).getJSONObject("colors").setString("background", "default");
  }
  
  ui.redrawElements();
  lastMouseRX = mouseX * 1280 / width; lastMouseRY = mouseY * 720 / height; //End of function 
}

boolean doesFileExist(String path, boolean clone){
  File file = new File(dataPath(path));
  if (file.exists()) {
    return true;
  } else {
    if (clone == true) {
      println(" Cloning: " + dataPath(path) + " From: " + github.getString(path));
      saveBytes("data/" + path, loadBytes(github.getString(path)));
    }
    return false;
  }
}

void keyPressed(){
  switch(key) {
    case 27:
      key = 0;
    break;
  }
}
void mousePressed() {
  if (ui.getElementIdByPosition(mouseRX, mouseRY) >= 0 && ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).hasKey("colors")) {
    ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").setString("background", "active");
  }
}

void mouseReleased() {
  if (ui.getElementIdByPosition(mouseRX, mouseRY) >= 0 && ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).hasKey("colors")) {
    ui.ElementsData.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").setString("background", "default");
    if (ui.getElementByPosition(mouseRX, mouseRY).hasKey("actions")) {
      runActionArray(ui.getElementByPosition(mouseRX, mouseRY).getJSONArray("actions"));
    }
  }
}

void runActionArray(JSONArray actions) {
  for (int i = 0; i < actions.size(); i++) {
    JSONObject action = actions.getJSONObject(i);
    switch (action.getString("type")) {
      default:
        println("Unknown Action: " + action.getString("type"));
      break;
      case "loadUI":
        ui.unload();
        ui.load(loadJSONObject(action.getString("file")));
      break;
      case "print":
        println(action.getString("text"));
      break;
      case "background-color":
        background(action.getInt("color"));
      break;
      case "redrawElements":
        ui.redrawElements();
      break;
      case "exit":
        exit();
      break;
      case "unloadUI":
        ui.unload();
      break;
    }
  }
}

class UI {
  JSONArray ElementsData = new JSONArray();
  
  void addElement(JSONObject element, boolean updateArray) {
    if (updateArray) {
      ElementsData.append(element);
    }
    switch(element.getString("type")) {
      default:
        println("Unknown Element Type: " + element.getString("type"));
      break;
      case "button":
        if (element.getJSONObject("colors").hasKey("border")) { stroke(element.getJSONObject("colors").getInt("border")); } else { noStroke(); } fill(element.getJSONObject("colors").getInt(element.getJSONObject("colors").getString("background"))); //Settings
        rect(element.getInt("x") * width / 1280, element.getInt("y") * height / 720, element.getInt("width") * width / 1280, element.getInt("height") * height / 720, element.getInt("radii"));
        textAlign(3, 3); fill(element.getJSONObject("colors").getInt("text")); textFont(fonts[element.getInt("font")]);//Settings
        text(element.getString("text"), (element.getInt("x") + element.getInt("width") / 2) * width / 1280, (element.getInt("y") + element.getInt("height") / 2) * height / 720);
      break;
      case "text":
        textAlign(3, 3); fill(element.getInt("color")); textFont(fonts[element.getInt("font")]); //Settings
        text(element.getString("text"), element.getInt("x") * width / 1280, element.getInt("y") * height / 720);
      break;
    }
  }
  
  JSONObject getElementByPosition(float x, float y) {
    for (int i = 0; i < ElementsData.size(); i++) {
      if (x > ElementsData.getJSONObject(i).getInt("x") && x < ElementsData.getJSONObject(i).getInt("x") + ElementsData.getJSONObject(i).getInt("width") && y > ElementsData.getJSONObject(i).getInt("y") && y < ElementsData.getJSONObject(i).getInt("y") + ElementsData.getJSONObject(i).getInt("height")) {
        return ElementsData.getJSONObject(i);
      }
    }
    return new JSONObject();
  }
  
  int getElementIdByPosition(float x, float y) {
    for (int i = 0; i < ElementsData.size(); i++) {
      if (x > ElementsData.getJSONObject(i).getInt("x") && x < ElementsData.getJSONObject(i).getInt("x") + ElementsData.getJSONObject(i).getInt("width") && y > ElementsData.getJSONObject(i).getInt("y") && y < ElementsData.getJSONObject(i).getInt("y") + ElementsData.getJSONObject(i).getInt("height")) {
        return i;
      }
    }
    return -1;
  }
  
  void load(JSONObject ui) {
    if (ui.hasKey("background-color")) {
      background(ui.getInt("background-color"));
    } else if (ui.hasKey("background-image")) {
      PImage bgIMG = loadImage(ui.getString("background-image"));
      bgIMG.resize(width, height);
      background(bgIMG);
    }
    
    for (int i = 0; i < ui.getJSONArray("elements").size(); i++) {
      addElement(ui.getJSONArray("elements").getJSONObject(i), true);
    }
  }
  
  void redrawElements() {
    for (int i = 0; i < ElementsData.size(); i++) {
      addElement(ElementsData.getJSONObject(i), false);
    }
  }
  
  void unload() {
    background(200);
    ElementsData = new JSONArray();
  }
}