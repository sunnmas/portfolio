<template lang="pug">
div
  Flash
  Loading(:show='loading_indicator')
  Fatal('v-if'='fatal')
  div('v-if'='loading')
    Skeleton
  div('v-if'='!loading && !fatal')
    h1 Смена пароля
    Form.narrow-form(name='change_password', method='patch', :csrf='csrf', @enter='submit')
      input(name='user[reset_password_token]', type='hidden', :value='token')
      input(name='_method', type='hidden', value='put')
      formFieldPassword(title='Новый пароль', required='true', name='user[password]', id='user_password', tabindex='100', placeholder='', :errors="password_field.errors", :original='password_field.original', 'v-model'='password', :autocomplete='"off"', :placeholder='"Придумайте новый пароль"', @input='validate_password', :disabled='false', autofocus='true')
      formFieldPassword(title='Повторите новый пароль', required='true', name='user[password_confirmation]', id='user_password_confirmation', tabindex='101', placeholder='', :errors="password_confirmation_field.errors", :original='password_confirmation_field.original', 'v-model'='password_confirmation',  :placeholder='"Повторите пароль"', @input='validate_password', :disabled='false')
 
      .actions
        .button.blue-button.inline(tabindex='102', @click='submit', @keydown.enter.prevent='submit', :class="{'inactive-button': !change_pass_action_active || !can_change}") Сменить пароль
</template>

<script lang="coffee">
import Flash from "./../../components/flash/flash.vue"
import Loading from "./../../components/loading/loading.vue"
import Fatal from "./../../components/fatal/fatal.vue"
import Skeleton from "./../../images/skeleton.svg"
import formFieldPassword from "./../../components/forms/formFieldPassword.vue"
export default
  name: 'change-password'
  methods:
    submit: ()->
      if !this.change_pass_action_active || !this.can_change
        this.$store.commit('PUSH_NOTIFY', {type: 'error', body: 'Заполните выделенные поля для смены пароля.'});
        return

      form = document.forms.change_password
      formData = new FormData(form)
      this.$store.dispatch('change_pass', formData)
    validate_password: ()->
      if this.password_confirmation != this.password
        this.$store.commit('PASSWORD_MISSMATCH', true)
      else
        this.$store.commit('PASSWORD_MISSMATCH', false)
  computed:
    fatal: ()->
      return this.$store.getters.fatal
    loading: ()->
      return this.$store.getters.loading
    loading_indicator: ()->
      return this.$store.getters.loading_indicator
    csrf: ()->
      return this.$store.getters.csrf
    change_pass_action_active: ()->
      return this.$store.getters.change_pass_action_active

    can_change: ()->
      return false if (this.password == null) or (this.password == '') or this.password_disabled
      return false if (this.password != this.password_confirmation)
      return true

    token: ()->
      return this.$store.getters.token

    password:
      get: ()->
        return this.$store.getters.password.val
      set: (value)->
        this.$store.commit('SET_FIELD', {'password': value})
    password_field: ()->
      return this.$store.getters.password

    password_confirmation:
      get: ()->
        return this.$store.getters.password_confirmation.val
      set: (value)->
        this.$store.commit('SET_FIELD', {'password_confirmation': value})
    password_confirmation_field: ()->
      return this.$store.getters.password_confirmation

  components:
    Flash: Flash
    Loading: Loading
    Fatal: Fatal
    Skeleton: Skeleton
    formFieldPassword: formFieldPassword
</script>

<style scoped>
</style>