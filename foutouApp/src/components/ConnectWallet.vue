<template>
	<el-dialog
		v-model="dialogVisible"
		title="连接钱包"
		width="30%"
		:before-close="handleClose"
	>
			<img src="/metamask-logo.png" class="wallet-logo" alt="" />
			<span class="wallet-name">MetaMask</span>
		<div class="wallet-msg">连接你的钱包，方便进行后续操作</div>
		<template #footer>
			<span class="dialog-footer">
				<el-button @click="dialogVisible = false">取消</el-button>
				<el-button type="primary" @click="connect">连接</el-button>
			</span>
		</template>
	</el-dialog>
</template>

<script lang="ts" setup>
import { ref } from "vue";
import { useEtherStore } from "@/store/etherStore";
import { ElMessageBox } from "element-plus";
import "element-plus/es/components/message-box/style/index";
import { ElMessage } from "element-plus";
import "element-plus/es/components/message/style/index";

const etherStore = useEtherStore();
const props = defineProps(["visible"]);

const dialogVisible = ref(props.visible);

const handleClose = (done: () => void) => {
	ElMessageBox.confirm("是否确认关闭该弹窗", {
		confirmButtonText: "确认",
		cancelButtonText: "取消",
	})
		.then(() => {
			done();
		})
		.catch(() => {
			// catch error
		});
};
const msg1 = () => {
	ElMessage({
		showClose: true,
		message: "你的钱包已经连接",
	});
};
const msg2 = () => {
	ElMessage({
		showClose: true,
		message: "连接成功",
		type: "success",
	});
};
const msg3 = () => {
	ElMessage({
		showClose: true,
		message: "连接失败",
		type: "error",
	});
};
async function connect() {
	if (etherStore.account) {
		msg1();
		dialogVisible.value = false;
		return;
	}
	await etherStore.connectWallet();
	etherStore.account ? msg2() : msg3();
	dialogVisible.value = false;
}
</script>
<style lang="scss" scoped>
.dialog-footer button:first-child {
	margin-right: 10px;
}
.wallet-logo{
	width: 2vw
}
.wallet-name{
	font-size: 2vw
}
.wallet-msg{
	margin: 1vw;
	font-size: 1.3vw;
}
</style>
