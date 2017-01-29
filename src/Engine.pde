float lastMouseRX, lastMouseRY, mouseRX, mouseRY = -1;

void draw() { 
  mouseRX = mouseX * 1280 / width; mouseRY = mouseY * 720 / height; //Beginning of function
  
  if (ui.getElementByPosition(mouseRX, mouseRY).hasKey("colors") && ui.getElementIdByPosition(mouseRX, mouseRY) >= 0 && ui.Elements.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").getString("background") != "active") {
    ui.Elements.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").setString("background", "highlight");
  }
  if (ui.getElementIdByPosition(mouseRX, mouseRY) == -1 && lastMouseRX != -1 && lastMouseRY != -1 && ui.getElementIdByPosition(lastMouseRX,lastMouseRY) >= 0 && ui.getElementByPosition(lastMouseRX, lastMouseRY).hasKey("colors")) {
    ui.Elements.getJSONObject(ui.getElementIdByPosition(lastMouseRX,lastMouseRY)).getJSONObject("colors").setString("background", "default");
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
  if (ui.getElementIdByPosition(mouseRX, mouseRY) >= 0 && ui.Elements.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).hasKey("colors")) {
    ui.Elements.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").setString("background", "active");
  }
}

void mouseReleased() {
  if (ui.getElementIdByPosition(mouseRX, mouseRY) >= 0 && ui.Elements.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).hasKey("colors")) {
    ui.Elements.getJSONObject(ui.getElementIdByPosition(mouseRX, mouseRY)).getJSONObject("colors").setString("background", "default");
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
      case "exit":
        exit();
      break;
      case "unloadUI":
        ui.unload();
      break;
      case "link":
        link(action.getString("link"));
      break;
      case "does-file-exist":
        doesFileExist(action.getString("path"), action.getBoolean("clone"));
      break;
    }
  }
}

class UI {
  JSONArray Elements = new JSONArray();
  PImage Images[]; PFont Fonts[]; String Strings[] [];
  
  void addElement(JSONObject element, boolean updateArray) {
    if (updateArray) {
      Elements.append(element);
    }
    switch(element.getString("type")) {
      default:
        println("Unknown Element Type: " + element.getString("type"));
      break;
      case "background":
        switch(element.getString("background")) {
          case "color":
            background(element.getInt("color"));
          break;
        }
      break;
      case "button":
        if (element.getJSONObject("colors").hasKey("border")) { stroke(element.getJSONObject("colors").getInt("border")); } else { noStroke(); } fill(element.getJSONObject("colors").getInt(element.getJSONObject("colors").getString("background"))); //Settings
        rect(element.getInt("x") * width / 1280, element.getInt("y") * height / 720, element.getInt("width") * width / 1280, element.getInt("height") * height / 720, element.getInt("radii"));
        textAlign(3, 3); fill(element.getJSONObject("colors").getInt("text")); textFont(Fonts[element.getInt("font")]);//Settings
        text(element.getString("text"), (element.getInt("x") + element.getInt("width") / 2) * width / 1280, (element.getInt("y") + element.getInt("height") / 2) * height / 720);
      break;
      case "text":
        textAlign(3, 3); fill(element.getInt("color")); textFont(Fonts[element.getInt("font")]); //Settings
        text(element.getString("text"), element.getInt("x") * width / 1280, element.getInt("y") * height / 720);
      break;
      case "image":
        image(Images[Images.length - 1], element.getInt("x") * width / 1280, element.getInt("y") * height / 720, element.getInt("height") * width / 1280, element.getInt("width") * height / 720);
      break;
      case "list":
        JSONObject list = new JSONObject();
        list.setString("type", element.getString("list")).setInt(element.getString("x-value"), element.getInt("x")).setInt(element.getString("y-value"), element.getInt("y"));
        for (int n = 0; n < element.getJSONArray("info").size(); n++) {
          JSONObject info = element.getJSONArray("info").getJSONObject(n);
          switch(info.getString("type")) {
            case "int":
              list.setInt(info.getString("name"), info.getInt("value"));
            break;
          }
        }
        for (int n = 0; n < Strings[element.getInt("data")].length; n++) {
          list.setString(element.getString("data-import"), Strings[element.getInt("data")][n]).setInt(element.getString("y-value"), list.getInt(element.getString("y-value")) + element.getInt("item-height"));
          addElement(list, false);
        }
      break;
    }
  }
  
  JSONObject getElementByPosition(float x, float y) {
    for (int i = 0; i < Elements.size(); i++) {
      if (Elements.getJSONObject(i).hasKey("width") && Elements.getJSONObject(i).hasKey("height") && x > Elements.getJSONObject(i).getInt("x") && x < Elements.getJSONObject(i).getInt("x") + Elements.getJSONObject(i).getInt("width") && y > Elements.getJSONObject(i).getInt("y") && y < Elements.getJSONObject(i).getInt("y") + Elements.getJSONObject(i).getInt("height")) {
        return Elements.getJSONObject(i);
      }
    }
    return new JSONObject();
  }
  
  int getElementIdByPosition(float x, float y) {
    for (int i = 0; i < Elements.size(); i++) {
      if (Elements.getJSONObject(i).hasKey("width") && Elements.getJSONObject(i).hasKey("height") && x > Elements.getJSONObject(i).getInt("x") && x < Elements.getJSONObject(i).getInt("x") + Elements.getJSONObject(i).getInt("width") && y > Elements.getJSONObject(i).getInt("y") && y < Elements.getJSONObject(i).getInt("y") + Elements.getJSONObject(i).getInt("height")) {
        return i;
      }
    }
    return -1;
  }
  
  void load(JSONObject ui) {
    loadFiles(ui.getJSONArray("files"));
    for (int i = 0; i < ui.getJSONArray("elements").size(); i++) {
      addElement(ui.getJSONArray("elements").getJSONObject(i), true);
    }
    printArray(Elements);
  }
  
  void redrawElements() {
    for (int i = 0; i < Elements.size(); i++) {
        addElement(Elements.getJSONObject(i), false);
    }
  }
  
  void unload() {
    background(200);
    Elements = new JSONArray();
  }
  
  void loadFiles(JSONArray files) {
    for (int i = 0; i < files.size(); i++) {
      JSONObject file = files.getJSONObject(i);
      switch(file.getString("type")) {
        default:
          println("Unkown File Type: " + file.getString("type"));
        break;
        case "images":
          JSONArray imageFiles = file.getJSONArray("images");
          Images = new PImage[imageFiles.size()];
          for (int f = 0; f < imageFiles.size(); f++) {
            Images[f] = loadImage(imageFiles.getJSONObject(f).getString("image"));
          }
        break;
        case "fonts":
          JSONArray fontFiles = file.getJSONArray("fonts");
          Fonts = new PFont[fontFiles.size()];
          for (int f = 0; f < fontFiles.size(); f++) {
            Fonts[f] = createFont(fontFiles.getJSONObject(f).getString("font"), fontFiles.getJSONObject(f).getInt("size") * width / 1280);
          }
        break;
        case "strings":
          JSONArray stringFiles = file.getJSONArray("strings");
          Strings = new String[stringFiles.size()] [];
          for (int f = 0; f < stringFiles.size(); f++) {
            Strings[f] = loadStrings(stringFiles.getJSONObject(f).getString("strings"));
          }
        break;
      }
    }
  }
}