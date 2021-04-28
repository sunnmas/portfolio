<template lang="pug">
div
  #set-avatar
      #upload-avatar(v-if="!active_special", @click="upload_avatar", title='Загрузить фото')
      #remove-avatar(v-if="active_special", @click="remove_avatar_ask", title='Удалить фото')
      .avatar(tabindex='7', :class="{'active': active_1}", @click='change_avatar_ask(1)', @keydown.enter.prevent='change_avatar_ask(1)', v-if="show_1")
        Avatar
      .avatar(tabindex='8', :class="{'active': active_2}", @click='change_avatar_ask(2)', @keydown.enter.prevent='change_avatar_ask(2)', v-if="show_2")
        Avatar2
      .avatar(tabindex='9', :class="{'active': active_3}", @click='change_avatar_ask(3)', @keydown.enter.prevent='change_avatar_ask(3)', v-if="show_3")
        Avatar3
      .avatar(tabindex='10', :class="{'active': active_4}", @click='change_avatar_ask(4)', @keydown.enter.prevent='change_avatar_ask(4)', v-if="show_4")
        Avatar4
      .avatar.active(tabindex='11', v-if="active_special", @keydown.46.prevent='remove_avatar_ask')
        img(ref='avatarImage', :src='avatar_url')
  #avatar-menu(tabindex='6', @click="switch_ava_menu", @keydown.enter.prevent='switch_ava_menu', title='Больше вариантов')
    AvatarMenu
  yesnoDialog(question='Вы действительно хотите удалить аватар?', @yesPressed='remove_avatar', 'v-model'='remove_avatar_dialog_visible')
  yesnoDialog(question='Сменить загруженный аватар?', @yesPressed='set(required_avatar)', 'v-model'='change_avatar_dialog_visible')
</template>

<script>
import axios from 'axios';
import yesnoDialog from "./../../components/dialogs/yesno.vue";
import AvatarMenu from "./avatar+.svg";
import Avatar from "./../../../../assets/images/svg/avatar-1.svg";
import Avatar2 from "./../../../../assets/images/svg/avatar-2.svg";
import Avatar3 from "./../../../../assets/images/svg/avatar-3.svg";
import Avatar4 from "./../../../../assets/images/svg/avatar-4.svg";
export default {
	name: 'avatarForm',
	methods: {
		set(val){
			if ((val == 1 && this.active_1) ||
				(val == 2 && this.active_2) ||
				(val == 3 && this.active_3) ||
				(val == 4 && this.active_4)) {
				this.upload_avatar();
				return;
			}
			this.$store.dispatch('change_avatar', val);
		},
		upload_avatar(){
			if (!this.change_avatar_action_active) {
				return;
			}
			this.$upload.select('profile-avatar');
		},
		remove_avatar(){
			if (!this.remove_avatar_action_active) {
				return;
			}
			this.$store.dispatch('remove_avatar');
		},
		change_avatar_ask(val) {
			if (!this.change_avatar_action_active) {
				return;
			}
			if (this.active_special) {
				this.$store.commit('SET_REQUIRED_AVATAR', val);
				this.change_avatar_dialog_visible = true;
			}
			else {
				this.set(val);
			}
		},
		remove_avatar_ask() {
			if (!this.remove_avatar_action_active) {
				return;
			}
			this.remove_avatar_dialog_visible = true;
		},
		switch_ava_menu() {
			this.$store.commit('EXPAND_AVATAR_MENU', !this.ava_menu);
		}
	},
	computed: {
		show_1() {
			return this.ava_menu || this.$store.getters.avatar==1;
		},
		show_2() {
			return this.ava_menu || this.$store.getters.avatar==2;
		},
		show_3() {
			return this.ava_menu || this.$store.getters.avatar==3;
		},
		show_4() {
			return this.ava_menu || this.$store.getters.avatar==4;
		},
		active_1() {
			return this.$store.getters.avatar==1;
		},
		active_2() {
			return this.$store.getters.avatar==2;
		},
		active_3() {
			return this.$store.getters.avatar==3;
		},
		active_4() {
			return this.$store.getters.avatar==4;
		},
		active_special() {
			return ![1,2,3,4].includes(parseInt(this.$store.getters.avatar));
		},
		avatar_url() {
			return this.$store.getters.avatar;
		},
		required_avatar() {
			return this.$store.getters.required_avatar;
		},
		change_avatar_action_active() {
			return this.$store.getters.change_avatar_action_active;
		},
		remove_avatar_action_active() {
			return this.$store.getters.remove_avatar_action_active;
		},
		remove_avatar_dialog_visible: {
		  get() {
		    return this.$store.getters.remove_avatar_dialog_visible;
		  },
		  set(value) {
		    this.$store.commit('REMOVE_AVATAR_DIALOG', value);
		  }
		},
		change_avatar_dialog_visible: {
		  get() {
		    return this.$store.getters.change_avatar_dialog_visible;
		  },
		  set(value) {
		    this.$store.commit('CHANGE_AVATAR_DIALOG', value);
		  }
		},
		ava_menu() {
			return this.$store.getters.avatar_menu_expanded;
		}
	},
	created() {
		var storage = this.$store;
		this.$upload.on('profile-avatar', {
			url: '/изменить/аватар',
			multiple: false,
			extensions: ['jpg', 'jpeg', 'png'],
			maxSizePerFile: 5*1024*1024,
			body: {'authenticity_token': storage.getters.csrf},
			http: function _http (data) {
				storage.commit('SET_LOADING_INDICATOR', true);
				storage.commit('SET_AVATAR_CHANGE_ACTION_ACTIVE', false);
				axios.post(data.url, data.body, { onUploadProgress: data.progress, headers: {'Accept': 'application/json',
								'Content-Type': 'application/json'}})
				.then((response) => {
					let d = response.data;
					storage.commit('PUSH_NOTIFY', {type: 'success', body: d.msg});
					storage.commit('SET_AVATAR', {avatar: d.avatar, path: d.path});
					storage.commit('SET_AVATAR_CHANGE_ACTION_ACTIVE', true);
				})
				.catch((error) => {
					let msg = error.response.data.msg;
					if (msg.indexOf('{file}') != -1) {
						msg = msg.replace('{file}', 'аватара');
					}
					storage.commit('PUSH_NOTIFY', {type: 'error', body: msg});
					storage.commit('SET_AVATAR_CHANGE_ACTION_ACTIVE', true);
				})
			},
			onError() {
				try {
					var err_code = this.$upload.files('profile-avatar').error[0].errors[0].code
					var err_msg;
					if (err_code == 'file-extension'){
						err_msg = 'Тип файла аватара должен быть один из: jpg, jpeg, png.'
					}
					else if (err_code == 'file-max-size') {
						err_msg = 'Максимально разрешенный размер файла составляет 5Мб.'
					}
					storage.commit('PUSH_NOTIFY', {type: 'error', body: err_msg});
				}
				catch {}
			}
		});
	},
	mounted: function(){
      let store = this.$store;
      // Если при старте приложения загружен аватар-картинка,
      // то проверяем ее на разрешение, при дальнейшей работе с 
      // аватаром неверное разрешение установить нельзя
      if (this.active_special) {
	  	this.$refs.avatarImage.addEventListener('load', function() {
      		if (this.naturalWidth < 200 || this.naturalHeight < 200) {
      			store.commit('AVATAR_TOO_SMALL', true);
      		}
      		else {
      			store.commit('AVATAR_TOO_SMALL', false);
      		}
      	});
      }
	},
	components: {
		yesnoDialog: yesnoDialog,
		AvatarMenu,
		Avatar,
		Avatar2,
		Avatar3,
		Avatar4
	}
}
</script>