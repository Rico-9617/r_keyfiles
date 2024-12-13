const CryptoJS = require('crypto-js');

// Function to create an AES encryptor
function createEncryptor(secretKey) {
  const key = CryptoJS.enc.Utf8.parse(secretKey.padEnd(16, '0').slice(0, 16));
  const options = {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.Pkcs7
  };
  return { key, options };
}

// Function to encrypt data
function encrypt(data, secretKey) {
  try {
    const { key, options } = createEncryptor(secretKey);
    const encrypted = CryptoJS.AES.encrypt(data, key, options);
    return CryptoJS.enc.Base64.stringify(encrypted.ciphertext);
  } catch (e) {
    console.error('encError:', e);
    return null;
  }
}

// Function to decrypt data
function decrypt(data, secretKey) {
  try {
    const { key, options } = createEncryptor(secretKey);
    const decrypted = CryptoJS.AES.decrypt(
      { ciphertext: CryptoJS.enc.Base64.parse(data) },
      key,
      options
    );
    return CryptoJS.enc.Utf8.stringify(decrypted);
  } catch (e) {
    console.error('decError:', e);
    return null;
  }
}

module.exports = { encrypt, decrypt };
