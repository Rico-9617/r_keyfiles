const CryptoJS = require('crypto-js');
import { encrypt, decrypt } from '../tools/EncryptTools';

const hostUrl = new URL('http://127.0.0.1:54321');
// const hostUrl = new URL(window.location.host);

var k;

export async function request(infos = {}) {
    try {
        const response = await fetch(`${hostUrl.protocol}//${hostUrl.host}${infos.url}`, {
            method: 'POST',
            headers: {
                ...infos.headers ?? {},
                'auth-param': infos.data ? CryptoJS.MD5(infos.data) : '',
            },
            body: infos.data ? infos.k1 ? encrypt(infos.data, infos.k1) : k ? encrypt(infos.data, k) : infos.data : infos.data,
        })

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`)
        }

        var resData = await response.text()

        if (resData) {
            resData = infos.k1 ? decrypt(resData, infos.k1) : k ? decrypt(resData, k) : resData
        }

        return resData;
    } catch (e) {
        console.error('Fetch error:', e);
        throw e;
    }
}