<template lang="pug">
div
  h1 Настройки профиля
  Form.profile-form(name='profileSettings', method='patch', :csrf='csrf', @enter='submit')
    .form-divider.bottom-spacer Основные настройки
    formFieldInput(title='Имя пользователя', required='true', name='user[name]', id='user_name', type='text', :errors="name_field.errors", :original='name_field.original', autofocus='autofocus', 'v-model'='name', tabindex='100', placeholder='Пример: Александр Виниаминович', :disabled='!update_settings_action_active', @enter='submit')

    formFieldInput(title='Email', required='true', name='user[email]', id='user_email', type='email', 'v-model'='email', tabindex='101', :errors='email_field.errors', :original='email_field.original', placeholder='Пример: my@email.ru', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('title'='Компания', 'name'='user[company]', 'v-model'='company', tabindex='102', :errors='company_field.errors', :original='company_field.original', :disabled='!update_settings_action_active', @enter='submit')

    .form-divider.both-spacer Интерфейс
    formFieldSelect('name'='user[theme]', 'title'='Цветовая схема', 'v-model'='theme', tabindex='103', :errors='theme_field.errors', :original='theme_field.original', :options='theme_field.options', :disabled='!update_settings_action_active', @enter='submit')

    formFieldSelect('name'='user[adv_list_type]', 'title'='Тип списка объявлений', 'v-model'='adv_list_type', tabindex='104', :errors='adv_list_type_field.errors', :original='adv_list_type_field.original', :options='adv_list_type_field.options', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[message_sound]', 'title'='Звук уведомлений', 'v-model'='message_sound', tabindex='105', :errors='message_sound_field.errors', :original='message_sound_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[error_sound]', 'title'='Звук ошибок', 'v-model'='error_sound', tabindex='106', :errors='error_sound_field.errors', :original='error_sound_field.original', :disabled='!update_settings_action_active', @enter='submit')
    
    .form-divider.both-spacer Уведомления на почту
    formFieldCheckbox('name'='user[notify_comments]', 'title'='О комментариях', 'v-model'='notify_comments', tabindex='107', :errors='notify_comments_field.errors', :original='notify_comments_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_petitions]', 'title'='О жалобах', 'v-model'='notify_petitions', tabindex='108', :errors='notify_petitions_field.errors', :original='notify_petitions_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_incomings]', 'title'='О пополнениях баланса', 'v-model'='notify_incomings', tabindex='109', :errors='notify_incomings_field.errors', :original='notify_incomings_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_publications]', 'title'='О публикациях своих объявлений', 'v-model'='notify_publications', tabindex='111', :errors='notify_publications_field.errors', :original='notify_publications_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_discount]', 'title'='О назначении скидки', 'v-model'='notify_discount', tabindex='112', :errors='notify_discount_field.errors', :original='notify_discount_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_expired]', 'title'='О просроченных объявлениях', 'v-model'='notify_expired', tabindex='113', :errors='notify_expired_field.errors', :original='notify_expired_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_service_expired]', 'title'='О завершении услуги', 'v-model'='notify_service_expired', tabindex='114', :errors='notify_service_expired_field.errors', :original='notify_service_expired_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_blocks]', 'title'='О блокировке объявления', 'v-model'='notify_blocks', tabindex='115', :errors='notify_blocks_field.errors', :original='notify_blocks_field.original', :disabled='!update_settings_action_active', @enter='submit')

    formFieldCheckbox('name'='user[notify_messages]', 'title'='Сообщения от других пользователей', 'v-model'='notify_messages', tabindex='116', :errors='notify_messages_field.errors', :original='notify_messages_field.original', :disabled='!update_settings_action_active', @enter='submit')

    .actions
      .button.blue-button.inline(tabindex='120', @click='submit', @keydown.enter.prevent='submit', :class="{'inactive-button': !modified || !update_settings_action_active}") Сохранить
  pageActions
    a.page-action#update-user-action(@click='submit', :disabled='!update_settings_action_active')
      svgSprite(name='save')
</template>

<script lang="coffee">
import Form from "./../../components/forms/form.vue"
import formFieldCheckbox from "./../../components/forms/formFieldCheckbox.vue"
import formFieldInput from "./../../components/forms/formFieldInput.vue"
import formFieldSelect from "./../../components/forms/formFieldSelect.vue"
import formErrorInspector from "./../../components/forms/formErrorInspector.vue"
import svgSprite from './../../components/svg_sprite/svgSprite.vue'
import pageActions from "./../../components/page_actions/pageActions.vue"
export default
  name: 'settings-form'
  methods:
    submit: ()->
      return if !this.modified or !this.update_settings_action_active
      this.$emit('submit', null)
  computed:
    modified: ()->
      return this.$store.getters.settings_modified
    name:
      get: ()->
        return this.$store.getters.name.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'name': value})
    name_field: ()->
      return this.$store.getters.name
    email:
      get: ()->
        return this.$store.getters.email.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'email': value})
    email_field: ()->
      return this.$store.getters.email
    company:
      get: ()->
        return this.$store.getters.company.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'company': value})
    company_field: ()->
      return this.$store.getters.company

    message_sound:
      get: ()->
        return this.$store.getters.message_sound.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'message_sound': value})
    message_sound_field: ()->
      return this.$store.getters.message_sound
    
    error_sound:
      get: ()->
        return this.$store.getters.error_sound.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'error_sound': value})
    error_sound_field: ()->
      return this.$store.getters.error_sound

    theme:
      get: ()->
        return this.$store.getters.theme.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'theme': value})
    theme_field: ()->
      return this.$store.getters.theme

    adv_list_type:
      get: ()->
        return this.$store.getters.adv_list_type.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'adv_list_type': value})
    adv_list_type_field: ()->
      return this.$store.getters.adv_list_type

    notify_comments:
      get: ()->
        return this.$store.getters.notify_comments.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_comments': value})
    notify_comments_field: ()->
      return this.$store.getters.notify_comments

    notify_petitions:
      get: ()->
        return this.$store.getters.notify_petitions.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_petitions': value})
    notify_petitions_field: ()->
      return this.$store.getters.notify_petitions

    notify_incomings:
      get: ()->
        return this.$store.getters.notify_incomings.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_incomings': value})
    notify_incomings_field: ()->
      return this.$store.getters.notify_incomings

    notify_publications:
      get: ()->
        return this.$store.getters.notify_publications.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_publications': value})
    notify_publications_field: ()->
      return this.$store.getters.notify_publications

    notify_discount:
      get: ()->
        return this.$store.getters.notify_discount.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_discount': value})
    notify_discount_field: ()->
      return this.$store.getters.notify_discount

    notify_expired:
      get: ()->
        return this.$store.getters.notify_expired.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_expired': value})
    notify_expired_field: ()->
      return this.$store.getters.notify_expired

    notify_service_expired:
      get: ()->
        return this.$store.getters.notify_service_expired.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_service_expired': value})
    notify_service_expired_field: ()->
      return this.$store.getters.notify_service_expired

    notify_blocks:
      get: ()->
        return this.$store.getters.notify_blocks.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_blocks': value})
    notify_blocks_field: ()->
      return this.$store.getters.notify_blocks

    notify_messages:
      get: ()->
        return this.$store.getters.notify_messages.val
      set: (value)->
        this.$store.commit('SET_SETTING', {'notify_messages': value})
    notify_messages_field: ()->
      return this.$store.getters.notify_messages

    update_settings_action_active: ()->
      return this.$store.getters.update_settings_action_active
    csrf: ()->
      return this.$store.getters.csrf
  components:
    Form: Form
    formFieldInput: formFieldInput
    formFieldCheckbox: formFieldCheckbox
    formFieldSelect: formFieldSelect
    formErrorInspector: formErrorInspector
    pageActions: pageActions
    svgSprite: svgSprite
</script>

<style lang="sass" scoped>
</style>