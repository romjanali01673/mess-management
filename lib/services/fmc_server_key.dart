import 'package:googleapis_auth/auth_io.dart';

class FmcServerKey {
  Future<String> getServerTockenFCM()async{
    final scopes =[
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
      // "https://www.googleapis.com/auth/cloud-platform",
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": "mess-management-b82d9",
          "private_key_id": "cd171427ab8e9e8bac47ca3e519bc94a5a44ceaf",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCsRYwLvjwevP9d\nbPHdYCwrXLnxxcT/ju93dvKZS4REb7PJ8v7boYD2lGue3W6JuiDlkp+aqSuXp0w9\nmA10QI1KuoKUz06fY3aYQ2c8fKoaKyYl67y996km0MWDiBYzf0ZctmwumHjqpRXZ\nu8G+k/4tatCs31CXcsBoV3kHBhdEmlBMmae18cTH8OcpYPOsD7OEm/7Hq79a25ih\n4UVOsW7RkQC8uKXW3rh9Ga+PWOshBum7rKiYTd90rMvjlHdfxamiyBPp/YiN5Pgk\nhlecjhLCzckp2dbUVgcQMGcmwEBBdQjlVEhrsY4nlh6lXUF7i1uEsP4djU8MctHR\npHgp1/d3AgMBAAECggEARHoOnXpcRnGk5juQdoksdX4R0Zdl45mq+Wc4LpQUeumV\n4y/qe14at6kukEL/ldJ9EhQyyhT1pX4UMaWXr36bSzmQ/1raK0Qrl4Gvbx00tlsx\nekBW0YI45Bt3b32wKX8tdlvy66Ci6858PYTDEiCcl+wOD7FixRiRf8hJbO/QXu17\nBBEMhEj8IF2aak+dXmSLDQ4wfdoFwpqPaSvd8kEXv5F+PyZA2+5ni5HA9TMH7zVQ\n1rI6ScctdfTDijAyIVYrbLJ2V7nH0viodOENa4FG9MKlZYVKrIaSJNQZ5sR2yHVE\n1JzvNddzXNl6WV7G/JO2W2oPftTnu9qA0R+LFmtALQKBgQDVyspaoOEW6jaj8BUs\n7/dDgtbPq+P6kLtdT3VdKVtxrp3ElnoJLXVIWqsOS3F/N2NNhv6BJxjsyzJVYTF6\nmQum2xX9uwbD1m9x3FS30wVvUetxuEcu7painqs6cm42crn9GVTJ7EF937Vc+Cup\nC/oRfkrc00Pq7btWNQM5jeqxQwKBgQDOSEgPaMRlvekDGR80MYZdGABqjBB0GSgt\nQJKk2pN7Tf2FU0MqrkOLit3J3cG0NUGEFIkJkqJJUhlK/ZndEGMpXgqCnQunxgDZ\nNlaFmPiq2aZFp68LWWKeRta/MV3Fdgfx6Jtfb8gaLvpM0IaU0iVTIilFm29GF0Fy\nwuXYYiZzvQKBgQCaHhI5uvgImNbC33OkbWiGVm+cTYGPQ36OCZXFjubI0OQSr5dR\nvl9pxVLCf0hWOQtw+/vEBvdE3EZwnhwZEPMBWbZErup1isPUBM1dptWoJhngZMOL\n5ZrZqCAvhgZFYfcJqZUh6xpbL0WCu7RdrLCco7o77mBrnu0JfDXS66dgGQKBgEX+\nFp1L4h/XgWGwu3q9NycNRs7gOZD7HDvGhjtzgsk63EPJzaeEu5x0gO7G1Lvtug4z\n3Y+m9nPEbJqaVAPDVLIrm4tX+CV0NMN/AXqRPgbSlO1biTRjnuevh5wWBwhCFU4K\nq/WE+zOPLxSzSIbkiw+bLr/UjrwMlgN3h/+UxhFNAoGATrzvIZdv90kazSUydqlm\nQeXT9fQ19IbY20hOxEY+sQnIO7Rwup8DrXvjTddJp7lBFfnsYFF9tCt/4jogHQky\n4sjNhvjOqnHy+GtBWIBeC5AyZRyiQxELSVrFfxfiKdjCsi+A0E8KklLdKiRr+tEI\nT7d8RxMILQ3vAI+tPlY57+c=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-fbsvc@mess-management-b82d9.iam.gserviceaccount.com",
          "client_id": "104740401041980624203",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40mess-management-b82d9.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
      ), 
      scopes      
    );

    final accessServerKey = client.credentials.accessToken.data;

    return accessServerKey;
  }
}