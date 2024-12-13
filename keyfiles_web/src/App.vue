<template>
  <img alt="Vue logo" src="./assets/logo.png">
  <FileList msg="Welcome to Your Vue.js App" />
  <Modal :is-visible="showPasscode">
    <PassCodeDialog />
  </Modal>
</template>

<script>
import Modal from './components/dialogs/ModalScaffold.vue';
import PassCodeDialog from './components/dialogs/PassCodeDialog.vue';
import FileList from './components/FileList.vue';

export default {
  name: 'App',
  components: {
    PassCodeDialog,
    Modal,
    FileList,
  },
  data() {
    return {
      showPasscode: false,
    };
  },
  mounted(){
    this.showPasscode = true;
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
