<template lang="pug">
div#geo-settings
  .wide-important-notification Вы можете добавить несколько часто используемых местоположений (мест осмотра) для Ваших будущих объявлений.
  h1 География
  .input-with-actions.with-three-actions
    formFieldSelect('name'='place', 'title'='Местоположения', 'v-model'='places.val', tabindex='101', autofocus='autofocus', :errors='places.errors', :original='places.original', :options='places.options', :disabled='false', @enter='change_place', @change='change_place', @destroy='remove_place_ask', @copy='add_place')
    .input-action(tabindex='102', @click='add_place', @keydown.enter.prevent='add_place', :class="{'inactive-button': !can_add_place}", title='Скопировать местоположение (F5)')
      svgSprite(name='add')
    .input-action.second-action(tabindex='103', @click='update_place', @keydown.enter.prevent='update_place', :class="{'inactive-button': !can_update_place}", title='Сохранить местоположение (Enter)')
      svgSprite(name='save', classs='green-to-white')
    .red-button.input-action.third-action(tabindex='104', @click='remove_place_ask', @keydown.enter.prevent='remove_place_ask', :class="{'inactive-button': !can_access_place}", title='Удалить местоположение (F8)')
      svgSprite(name='remove', classs='red-to-white')
  .separator.both-spacer
  basicGeoForm('start_tab_index'='105', model='user', :disabled='false', :can_manipulate='true', @copy='add_place', @destroy='remove_place_ask', @update='update_place')
  .actions
    .button.blue-button.inline(tabindex='119', @click='update_place', @keydown.enter.prevent='update_place', :class="{'inactive-button': !can_update_place}", title='Сохранить местоположение (Enter)') Сохранить
  pageActions
    a.page-action#update-user-action(@click='update_place', :disabled='!can_update_place')
      svgSprite(name='save')
  yesnoDialog(question='Вы действительно хотите удалить местоположение?', @yesPressed='remove_place', 'v-model'='remove_place_dialog_visible')
</template>

<script lang="coffee">
# 
import Form from "./../../components/forms/form.vue"
import formFieldInput from "./../../components/forms/formFieldInput.vue"
import formFieldSelect from "./../../components/forms/formFieldSelect.vue"
import yesnoDialog from "./../../components/dialogs/yesno.vue";
import svgSprite from './../../components/svg_sprite/svgSprite.vue'
import pageActions from "./../../components/page_actions/pageActions.vue"
import basicGeoForm from "./../../components/geo/basic_geo_form.vue"
export default
  name: 'geo-form'
  computed:
    places: ()->
      return this.$store.getters.places

    can_access_place: ()->
      try
        return false if !this.remove_place_action_active
        return false if !this.update_place_action_active
        return true
      catch e
        return false
    can_add_place: ()->
      return true if this.add_place_action_active and this.can_access_place
      return false
    can_update_place: ()->
      return true if this.$store.getters.is_curr_geo_place_modified and this.can_access_place
      return false
    add_place_action_active: ()->
      return this.$store.getters.add_place_action_active
    update_place_action_active: ()->
      return this.$store.getters.update_place_action_active
    remove_place_action_active: ()->
      return this.$store.getters.remove_place_action_active
    remove_place_dialog_visible:
      get: ()->
        return this.$store.getters.remove_place_dialog_visible
      set: (value)->
        this.$store.commit('REMOVE_PLACE_DIALOG', value)
      
  methods:
    change_place: ()->
      this.$store.commit('CHANGE_PLACE')

    add_place: ()->
      return if !this.can_add_place
      this.$store.dispatch 'add_place'
    update_place: ()->
      return if !this.can_update_place
      this.$store.dispatch 'update_place'
    remove_place_ask: (e)->
      return if !this.can_access_place
      this.remove_place_dialog_visible = true
    remove_place: ()->
      return if !this.can_access_place
      this.$store.dispatch 'remove_place'
  components:
    Form: Form
    formFieldInput: formFieldInput
    formFieldSelect: formFieldSelect
    yesnoDialog: yesnoDialog
    svgSprite: svgSprite
    pageActions: pageActions
    basicGeoForm: basicGeoForm
</script>