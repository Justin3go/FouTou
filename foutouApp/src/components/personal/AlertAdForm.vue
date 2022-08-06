<template>
	<el-dialog v-model="dialogVisible" title="输入图片链接" width="30%" draggable>
		<el-input v-model="newAdUrl" placeholder="输入url，不支持上传本地图片，比例5:1" size="large" clearable autofocus/>
		<template #footer>
			<span class="dialog-footer">
				<el-button @click="dialogVisible = false">取消</el-button>
				<el-button>预览</el-button>
				<el-button type="primary" @click="submit">提交</el-button>
			</span>
		</template>
	</el-dialog>
</template>
<script setup lang="ts">
import { ref } from "vue";

const dialogVisible = ref(false);
const newAdUrl = ref('');

defineExpose({
  dialogVisible
})
// todo 还是做一个图片预览比较好
async function submit(){
	
}
</script>
