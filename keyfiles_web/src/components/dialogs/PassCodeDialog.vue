<template>
    <div class="rectangle">
        <h1 class="title">请输入验证码</h1>
        <input type="text" class="input-code input-text" v-model="code" />
        <button class="button" @click="submit">ok</button>
    </div>
</template>

<script>
import { ref } from 'vue';
import { request } from '@/js/server/FetchTools';
const CryptoJS = require('crypto-js');

export default {
    setup() {
        const code = ref('')
        async function submit() {
            console.log('submitcode ', CryptoJS.MD5(code.value).toString())
            const data = CryptoJS.MD5(code.value).toString()
            const response = await request({url:'/api/verify', data: data,k1: data.slice(data.length - 8,data.length)})
            console.log('testfetch  ',data,'   res=',response)
        }
        return {
            code,
            submit
        }
    }
}

</script>

<style scoped>
.rectangle {
    width: 300px;
    background-color: var(--color-dialog-content-bg);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 16px 0;
}

.title {
    color: var(--color-text-0);
    font-size: var(--text-list-title);
    text-align: center;
    margin: 0;
    margin-bottom: 16px;
}

.input-code {
    width: calc(100% - 32px);
    margin: 0 16px;
    margin-bottom: 16px;
    text-align: center;
    font-size: 20px;
    font-weight: 500;
}

.button {
    background-color: var(--color-button-bg);
    color: white;
    font-size: var(--text-dialog_button);
    border: none;
    padding: 8px 16px;
    cursor: pointer;
}
</style>