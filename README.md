# Flutter AI Chat

TODO

# Getting Started

This sample relies on a Firebase project, which you then initialize in your app. You can learn how to set that up with the steps described in [the Get started with the Gemini API using the Vertex AI in Firebase SDKs docs](https://firebase.google.com/docs/vertex-ai/get-started?platform=flutter).

## Firebase Auth

Once you have your Firebase project in place, you'll need to [configure Firebase Auth with support for the Email auth provider](https://github.com/firebase/FirebaseUI-Flutter/blob/main/docs/firebase-ui-auth/providers/email.md) to enable your users to create new accounts and store their chats. The project has all of the necessary code, so it's just a matter of enabling the "Email/Password" provider in the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers).

## Cloud Firestore

And finally, you'll need to create the default Cloud Firestore database to store your users' chats. The [Create a Cloud Firestore database docs](https://firebase.google.com/docs/firestore/quickstart#create) will show you how to do that.

Once you have your database created, you can secure it according to [the Firebase Security Rules docs for Content-owner only access](https://firebase.google.com/docs/rules/basics#content-owner_only_access) using rules like these:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{documents=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId
    }
  }
}
```

## Firebase AppCheck

In addition, for maximum security, I recommend configuring your own apps with [Firebase AppCheck](https://firebase.google.com/learn/pathways/firebase-app-check).

# Features

TODO

## Multi-platform

This sample has been tested and works on all supported Firebase platforms: Android, iOS, web and macOS.

# Feedback

Are you having trouble with this app even after it's been configured correctly? Feel free to drop issues or, even better, PRs, into [the flutter_ai_chat repo](https://github.com/csells/flutter_ai_chat).