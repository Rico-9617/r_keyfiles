<template>
    <div class="fileList">
      <h1>{{ msg }}</h1>
      
    </div>
  </template>
  
  <script>
  export default {
    name: 'FileList',
    props: {
      msg: String
    }
  }
  </script>