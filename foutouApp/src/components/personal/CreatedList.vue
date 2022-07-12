<template>
	<h1>Created List</h1>
  <h2>{{ info.ownedFT }}</h2>
</template>
<script setup lang="ts">
import { onMounted } from "vue";
import { Person } from "@/api/etherApi";

const props = defineProps<{ account: string }>();
const info = reactive({ ownedFT: [] as number[] });
// todo 应该将那些get相关的都该为分页查询
// ？ 后续如果从这边的第二页跳转到那边，然后再回来，是否需要保存之前的状态呢，又使用哪种方法进行保存
onMounted(async () => {
  // 1.根据账户获取所创建FT的所有id
  info.ownedFT = await Person.getPER_ownedFT(props.account);
  // 2.根据每个id去重复查询每个FT的具体信息，这里合约里还可以优化
});
</script>
