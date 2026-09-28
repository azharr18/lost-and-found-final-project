importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAvI7MCEp4uA06SMhffA46cmx31iqE-E7s',
  appId: '1:218278266679:web:ac211d9ac876cfcedefcb2',
  messagingSenderId: '218278266679',
  projectId: 'lostandfound-2d3d5',
  authDomain: 'lostandfound-2d3d5.firebaseapp.com',
  storageBucket: 'lostandfound-2d3d5.firebasestorage.app'
});

const messaging = firebase.messaging();
