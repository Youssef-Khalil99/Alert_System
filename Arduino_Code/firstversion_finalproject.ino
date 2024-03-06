

#include <ArduinoJson.h>            // https://github.com/bblanchon/ArduinoJson 
#include <ESP32Firebase.h>

#define _SSID "Redmi Note 9S"          // Your WiFi SSID 
#define _PASSWORD "1234567890"      // Your WiFi Password 
#define REFERENCE_URL "https://camera-app-5f678-default-rtdb.firebaseio.com/"  // Your Firebase project reference url 

Firebase firebase(REFERENCE_URL);

#define RELAY_PIN 12
#define INIT_PIN 26
#define MED_PIN 25
#define SELFD_DRIVE_PIN 32

void setup() {

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(INIT_PIN, OUTPUT);
  pinMode(MED_PIN, OUTPUT);
  pinMode(SELFD_DRIVE_PIN, OUTPUT);


  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(1000);

  // Connect to WiFi
  Serial.println();
  Serial.println();
  Serial.print("Connecting to: ");
  Serial.println(_SSID);
  WiFi.begin(_SSID, _PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print("-");
  }

  Serial.println("");
  Serial.println("WiFi Connected");

  // Print the IP address
  Serial.print("IP Address: ");
  Serial.print("http://");
  Serial.print(WiFi.localIP());
  Serial.println("/");
  // digitalWrite(LED_BUILTIN, HIGH);

//================================================================//
//================================================================//


  firebase.json(true);             
  
  
  
}

void loop() {
  String data = firebase.getString("data");  // Get data from the database.

  // Deserialize the data.
  // Consider using Arduino Json Assistant- https://arduinojson.org/v6/assistant/
  const size_t capacity = JSON_OBJECT_SIZE(3) + 50;
  DynamicJsonDocument doc(capacity);

  deserializeJson(doc, data);

  // Store the deserialized data.
  
  int received_int1 = doc["image"];    
  int received_int2 = doc["level"];              // 123
  //float received_float = doc["setFloat"];         // 45.32

  // Print data
  

  Serial.print("Received Int1:\t\t");
  Serial.println(received_int1);

  Serial.print("Received Int2:\t\t");
  Serial.println(received_int2);


  

  if (received_int2 >= 1) {
    digitalWrite(INIT_PIN, HIGH);
    Serial.println("initpin is running");
  }

  if (received_int2 >= 2) {
    digitalWrite(MED_PIN, HIGH);
    Serial.println("medPin is running");
    
    
  }

  if (received_int2 >= 3) {
    digitalWrite(RELAY_PIN, HIGH);
    Serial.println("Motor is running");
  }

  if (received_int2 >= 4) {
    digitalWrite(SELFD_DRIVE_PIN, HIGH);
    Serial.println("selfdrive is running");
  }

  if (received_int2 < 1) {
    digitalWrite(INIT_PIN, LOW);
    Serial.println("initpin stopped");

    digitalWrite(MED_PIN, LOW);
    Serial.println("medPin stopped");

    digitalWrite(SELFD_DRIVE_PIN, LOW);
    Serial.println("selfdrive stopped");

    digitalWrite(RELAY_PIN, LOW);
    Serial.println("Motor stopped");
  }

  delay(100);  // Adjust the delay as neededs
}
