<template>
  <div v-if="isVisible" class="modal-page" :style="{ zIndex: zIndex }">
      <slot></slot> 
  </div>
</template>

<script>
export default {
  props: {
    zIndex: { type: Number, default: 9990 },
    isVisible: {
      type: Boolean,
      required: true
    }
  },
  methods: {
    close() {
      this.$emit('close');
    }
  }
}
</script>

<style scoped>
.modal-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}
 
</style>