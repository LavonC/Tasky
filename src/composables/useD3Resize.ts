import { ref, onMounted, onUnmounted } from 'vue';

export function useD3Resize(
  containerRef: { value: HTMLElement | null | undefined },
  callback: () => void,
) {
  const resizeObserver = ref<ResizeObserver | null>(null);

  onMounted(() => {
    if (containerRef.value) {
      resizeObserver.value = new ResizeObserver(() => {
        callback();
      });
      resizeObserver.value.observe(containerRef.value);
    }
  });

  onUnmounted(() => {
    if (resizeObserver.value) {
      resizeObserver.value.disconnect();
    }
  });

  return { resizeObserver };
}