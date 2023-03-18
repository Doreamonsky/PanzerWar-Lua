---@class ShanghaiWindy.Core.BaseFireSystem
local BaseFireSystem = {}

---@instance
---@function [BaseFireSystem.get_OnDamagedInternalModule]
function BaseFireSystem.get_OnDamagedInternalModule() end
---@instance
---@function [BaseFireSystem.set_OnDamagedInternalModule]
function BaseFireSystem.set_OnDamagedInternalModule(value) end
---@instance
---@function [BaseFireSystem.get_OnBulletApplyDamage]
function BaseFireSystem.get_OnBulletApplyDamage() end
---@instance
---@function [BaseFireSystem.set_OnBulletApplyDamage]
function BaseFireSystem.set_OnBulletApplyDamage(value) end
---@instance
---@function [BaseFireSystem.get_OnBulletFired]
function BaseFireSystem.get_OnBulletFired() end
---@instance
---@function [BaseFireSystem.set_OnBulletFired]
function BaseFireSystem.set_OnBulletFired(value) end
---@instance
---@function [BaseFireSystem.get_OnRestored]
function BaseFireSystem.get_OnRestored() end
---@instance
---@function [BaseFireSystem.set_OnRestored]
function BaseFireSystem.set_OnRestored(value) end
---@instance
---@function [BaseFireSystem.get_OnHitGodMode]
function BaseFireSystem.get_OnHitGodMode() end
---@instance
---@function [BaseFireSystem.set_OnHitGodMode]
function BaseFireSystem.set_OnHitGodMode(value) end
---@instance
---@function [BaseFireSystem.get_isShowHitDamage]
function BaseFireSystem.get_isShowHitDamage() end
---@instance
---@function [BaseFireSystem.AddDamage]
function BaseFireSystem.AddDamage(damage, hitVehicle, hitPos) end
---@instance
---@function [BaseFireSystem.HitFriend]
function BaseFireSystem.HitFriend(Vehicle) end
---@instance
---@function [BaseFireSystem.DestroyVehicle]
function BaseFireSystem.DestroyVehicle(Vehicle) end
---@instance
---@function [BaseFireSystem.NotPierced]
function BaseFireSystem.NotPierced(armor) end
---@instance
---@function [BaseFireSystem.Ricochet]
function BaseFireSystem.Ricochet() end
---@instance
---@function [BaseFireSystem.TryDamageViaBulletUID]
function BaseFireSystem.TryDamageViaBulletUID(bulletUID) end
---@instance
---@function [BaseFireSystem.SetIndex]
function BaseFireSystem.SetIndex(index) end
---@instance
---@function [BaseFireSystem.GetIndex]
function BaseFireSystem.GetIndex() end
---@instance
---@function [BaseFireSystem.get_baseInitSystem]
function BaseFireSystem.get_baseInitSystem() end
---@instance
---@function [BaseFireSystem.ApplyInitSystem]
function BaseFireSystem.ApplyInitSystem(t) end
---@instance
---@function [BaseFireSystem.IsInvoking]
function BaseFireSystem.IsInvoking() end
---@instance
---@function [BaseFireSystem.CancelInvoke]
function BaseFireSystem.CancelInvoke() end
---@instance
---@function [BaseFireSystem.Invoke]
function BaseFireSystem.Invoke(methodName, time) end
---@instance
---@function [BaseFireSystem.InvokeRepeating]
function BaseFireSystem.InvokeRepeating(methodName, time, repeatRate) end
---@instance
---@function [BaseFireSystem.CancelInvoke]
function BaseFireSystem.CancelInvoke(methodName) end
---@instance
---@function [BaseFireSystem.IsInvoking]
function BaseFireSystem.IsInvoking(methodName) end
---@instance
---@function [BaseFireSystem.StartCoroutine]
function BaseFireSystem.StartCoroutine(methodName) end
---@instance
---@function [BaseFireSystem.StartCoroutine]
function BaseFireSystem.StartCoroutine(methodName, value) end
---@instance
---@function [BaseFireSystem.StartCoroutine]
function BaseFireSystem.StartCoroutine(routine) end
---@instance
---@function [BaseFireSystem.StartCoroutine_Auto]
function BaseFireSystem.StartCoroutine_Auto(routine) end
---@instance
---@function [BaseFireSystem.StopCoroutine]
function BaseFireSystem.StopCoroutine(routine) end
---@instance
---@function [BaseFireSystem.StopCoroutine]
function BaseFireSystem.StopCoroutine(routine) end
---@instance
---@function [BaseFireSystem.StopCoroutine]
function BaseFireSystem.StopCoroutine(methodName) end
---@instance
---@function [BaseFireSystem.StopAllCoroutines]
function BaseFireSystem.StopAllCoroutines() end
---@instance
---@function [BaseFireSystem.get_useGUILayout]
function BaseFireSystem.get_useGUILayout() end
---@instance
---@function [BaseFireSystem.set_useGUILayout]
function BaseFireSystem.set_useGUILayout(value) end
---@instance
---@function [BaseFireSystem.get_runInEditMode]
function BaseFireSystem.get_runInEditMode() end
---@instance
---@function [BaseFireSystem.set_runInEditMode]
function BaseFireSystem.set_runInEditMode(value) end
---@instance
---@function [BaseFireSystem.get_enabled]
function BaseFireSystem.get_enabled() end
---@instance
---@function [BaseFireSystem.set_enabled]
function BaseFireSystem.set_enabled(value) end
---@instance
---@function [BaseFireSystem.get_isActiveAndEnabled]
function BaseFireSystem.get_isActiveAndEnabled() end
---@instance
---@function [BaseFireSystem.get_transform]
function BaseFireSystem.get_transform() end
---@instance
---@function [BaseFireSystem.get_gameObject]
function BaseFireSystem.get_gameObject() end
---@instance
---@function [BaseFireSystem.GetComponent]
function BaseFireSystem.GetComponent(type) end
---@instance
---@function [BaseFireSystem.GetComponent]
function BaseFireSystem.GetComponent() end
---@instance
---@function [BaseFireSystem.TryGetComponent]
function BaseFireSystem.TryGetComponent(type, component) end
---@instance
---@function [BaseFireSystem.TryGetComponent]
function BaseFireSystem.TryGetComponent(component) end
---@instance
---@function [BaseFireSystem.GetComponent]
function BaseFireSystem.GetComponent(type) end
---@instance
---@function [BaseFireSystem.GetComponentInChildren]
function BaseFireSystem.GetComponentInChildren(t, includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentInChildren]
function BaseFireSystem.GetComponentInChildren(t) end
---@instance
---@function [BaseFireSystem.GetComponentInChildren]
function BaseFireSystem.GetComponentInChildren(includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentInChildren]
function BaseFireSystem.GetComponentInChildren() end
---@instance
---@function [BaseFireSystem.GetComponentsInChildren]
function BaseFireSystem.GetComponentsInChildren(t, includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentsInChildren]
function BaseFireSystem.GetComponentsInChildren(t) end
---@instance
---@function [BaseFireSystem.GetComponentsInChildren]
function BaseFireSystem.GetComponentsInChildren(includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentsInChildren]
function BaseFireSystem.GetComponentsInChildren(includeInactive, result) end
---@instance
---@function [BaseFireSystem.GetComponentsInChildren]
function BaseFireSystem.GetComponentsInChildren() end
---@instance
---@function [BaseFireSystem.GetComponentsInChildren]
function BaseFireSystem.GetComponentsInChildren(results) end
---@instance
---@function [BaseFireSystem.GetComponentInParent]
function BaseFireSystem.GetComponentInParent(t, includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentInParent]
function BaseFireSystem.GetComponentInParent(t) end
---@instance
---@function [BaseFireSystem.GetComponentInParent]
function BaseFireSystem.GetComponentInParent(includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentInParent]
function BaseFireSystem.GetComponentInParent() end
---@instance
---@function [BaseFireSystem.GetComponentsInParent]
function BaseFireSystem.GetComponentsInParent(t, includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentsInParent]
function BaseFireSystem.GetComponentsInParent(t) end
---@instance
---@function [BaseFireSystem.GetComponentsInParent]
function BaseFireSystem.GetComponentsInParent(includeInactive) end
---@instance
---@function [BaseFireSystem.GetComponentsInParent]
function BaseFireSystem.GetComponentsInParent(includeInactive, results) end
---@instance
---@function [BaseFireSystem.GetComponentsInParent]
function BaseFireSystem.GetComponentsInParent() end
---@instance
---@function [BaseFireSystem.GetComponents]
function BaseFireSystem.GetComponents(type) end
---@instance
---@function [BaseFireSystem.GetComponents]
function BaseFireSystem.GetComponents(type, results) end
---@instance
---@function [BaseFireSystem.GetComponents]
function BaseFireSystem.GetComponents(results) end
---@instance
---@function [BaseFireSystem.get_tag]
function BaseFireSystem.get_tag() end
---@instance
---@function [BaseFireSystem.set_tag]
function BaseFireSystem.set_tag(value) end
---@instance
---@function [BaseFireSystem.GetComponents]
function BaseFireSystem.GetComponents() end
---@instance
---@function [BaseFireSystem.CompareTag]
function BaseFireSystem.CompareTag(tag) end
---@instance
---@function [BaseFireSystem.SendMessageUpwards]
function BaseFireSystem.SendMessageUpwards(methodName, value, options) end
---@instance
---@function [BaseFireSystem.SendMessageUpwards]
function BaseFireSystem.SendMessageUpwards(methodName, value) end
---@instance
---@function [BaseFireSystem.SendMessageUpwards]
function BaseFireSystem.SendMessageUpwards(methodName) end
---@instance
---@function [BaseFireSystem.SendMessageUpwards]
function BaseFireSystem.SendMessageUpwards(methodName, options) end
---@instance
---@function [BaseFireSystem.SendMessage]
function BaseFireSystem.SendMessage(methodName, value) end
---@instance
---@function [BaseFireSystem.SendMessage]
function BaseFireSystem.SendMessage(methodName) end
---@instance
---@function [BaseFireSystem.SendMessage]
function BaseFireSystem.SendMessage(methodName, value, options) end
---@instance
---@function [BaseFireSystem.SendMessage]
function BaseFireSystem.SendMessage(methodName, options) end
---@instance
---@function [BaseFireSystem.BroadcastMessage]
function BaseFireSystem.BroadcastMessage(methodName, parameter, options) end
---@instance
---@function [BaseFireSystem.BroadcastMessage]
function BaseFireSystem.BroadcastMessage(methodName, parameter) end
---@instance
---@function [BaseFireSystem.BroadcastMessage]
function BaseFireSystem.BroadcastMessage(methodName) end
---@instance
---@function [BaseFireSystem.BroadcastMessage]
function BaseFireSystem.BroadcastMessage(methodName, options) end
---@instance
---@function [BaseFireSystem.get_rigidbody]
function BaseFireSystem.get_rigidbody() end
---@instance
---@function [BaseFireSystem.get_rigidbody2D]
function BaseFireSystem.get_rigidbody2D() end
---@instance
---@function [BaseFireSystem.get_camera]
function BaseFireSystem.get_camera() end
---@instance
---@function [BaseFireSystem.get_light]
function BaseFireSystem.get_light() end
---@instance
---@function [BaseFireSystem.get_animation]
function BaseFireSystem.get_animation() end
---@instance
---@function [BaseFireSystem.get_constantForce]
function BaseFireSystem.get_constantForce() end
---@instance
---@function [BaseFireSystem.get_renderer]
function BaseFireSystem.get_renderer() end
---@instance
---@function [BaseFireSystem.get_audio]
function BaseFireSystem.get_audio() end
---@instance
---@function [BaseFireSystem.get_networkView]
function BaseFireSystem.get_networkView() end
---@instance
---@function [BaseFireSystem.get_collider]
function BaseFireSystem.get_collider() end
---@instance
---@function [BaseFireSystem.get_collider2D]
function BaseFireSystem.get_collider2D() end
---@instance
---@function [BaseFireSystem.get_hingeJoint]
function BaseFireSystem.get_hingeJoint() end
---@instance
---@function [BaseFireSystem.get_particleSystem]
function BaseFireSystem.get_particleSystem() end
---@instance
---@function [BaseFireSystem.GetInstanceID]
function BaseFireSystem.GetInstanceID() end
---@instance
---@function [BaseFireSystem.GetHashCode]
function BaseFireSystem.GetHashCode() end
---@instance
---@function [BaseFireSystem.Equals]
function BaseFireSystem.Equals(other) end
---@instance
---@function [BaseFireSystem.get_name]
function BaseFireSystem.get_name() end
---@instance
---@function [BaseFireSystem.set_name]
function BaseFireSystem.set_name(value) end
---@instance
---@function [BaseFireSystem.get_hideFlags]
function BaseFireSystem.get_hideFlags() end
---@instance
---@function [BaseFireSystem.set_hideFlags]
function BaseFireSystem.set_hideFlags(value) end
---@instance
---@function [BaseFireSystem.ToString]
function BaseFireSystem.ToString() end
---@instance
---@function [BaseFireSystem.GetType]
function BaseFireSystem.GetType() end
return BaseFireSystem

---@class ShanghaiWindy.Core.BaseInitSystem
local BaseInitSystem = {}

---@instance
---@function [BaseInitSystem.get_OnVehicleLoaded]
function BaseInitSystem.get_OnVehicleLoaded() end
---@instance
---@function [BaseInitSystem.set_OnVehicleLoaded]
function BaseInitSystem.set_OnVehicleLoaded(value) end
---@instance
---@function [BaseInitSystem.get_OnVehicleDestroyed]
function BaseInitSystem.get_OnVehicleDestroyed() end
---@instance
---@function [BaseInitSystem.set_OnVehicleDestroyed]
function BaseInitSystem.set_OnVehicleDestroyed(value) end
---@instance
---@function [BaseInitSystem.get_OnGameObjectDestroyed]
function BaseInitSystem.get_OnGameObjectDestroyed() end
---@instance
---@function [BaseInitSystem.set_OnGameObjectDestroyed]
function BaseInitSystem.set_OnGameObjectDestroyed(value) end
---@instance
---@function [BaseInitSystem.get_OnDamagedInternalModule]
function BaseInitSystem.get_OnDamagedInternalModule() end
---@instance
---@function [BaseInitSystem.set_OnDamagedInternalModule]
function BaseInitSystem.set_OnDamagedInternalModule(value) end
---@static
---@function [BaseInitSystem.IsBot]
function BaseInitSystem.IsBot(netType) end
---@static
---@function [BaseInitSystem.IsGarage]
function BaseInitSystem.IsGarage(netType) end
---@static
---@function [BaseInitSystem.IsLocalPlayer]
function BaseInitSystem.IsLocalPlayer(netType) end
---@instance
---@function [BaseInitSystem.Start]
function BaseInitSystem.Start() end
---@instance
---@function [BaseInitSystem.OnDestroy]
function BaseInitSystem.OnDestroy() end
---@instance
---@function [BaseInitSystem.Update]
function BaseInitSystem.Update() end
---@instance
---@function [BaseInitSystem.OpenGMTool]
function BaseInitSystem.OpenGMTool() end
---@static
---@function [BaseInitSystem.IsMobileInput]
function BaseInitSystem.IsMobileInput() end
---@instance
---@function [BaseInitSystem.IsMobile]
function BaseInitSystem.IsMobile() end
---@instance
---@function [BaseInitSystem.ToggleToPlayerControl]
function BaseInitSystem.ToggleToPlayerControl(OnPlayerDestroyed) end
---@instance
---@function [BaseInitSystem.OnDynamicDataPatch]
function BaseInitSystem.OnDynamicDataPatch() end
---@instance
---@function [BaseInitSystem.AddDynamnicDataPatcher]
function BaseInitSystem.AddDynamnicDataPatcher(item) end
---@instance
---@function [BaseInitSystem.ApplyVehicleCamoData]
function BaseInitSystem.ApplyVehicleCamoData() end
---@static
---@function [BaseInitSystem.ApplySRPMat]
function BaseInitSystem.ApplySRPMat(coreRPMatComponents, meshRenderers, isSmoothness) end
---@static
---@function [BaseInitSystem.ApplySRPLitMat]
function BaseInitSystem.ApplySRPLitMat(coreRPMatComponents, meshRenderers, isSmoothness) end
---@instance
---@function [BaseInitSystem.ApplyCamo]
function BaseInitSystem.ApplyCamo(season, camouflageData, dirtRange, maskTexGuid, intensity) end
---@instance
---@function [BaseInitSystem.SetIndex]
function BaseInitSystem.SetIndex(index) end
---@instance
---@function [BaseInitSystem.GetIndex]
function BaseInitSystem.GetIndex() end
---@instance
---@function [BaseInitSystem.GetRigidbody]
function BaseInitSystem.GetRigidbody() end
---@instance
---@function [BaseInitSystem.GetFireLockComponent]
function BaseInitSystem.GetFireLockComponent() end
---@instance
---@function [BaseInitSystem.GetTextureRefs]
function BaseInitSystem.GetTextureRefs() end
---@instance
---@function [BaseInitSystem.ApplyLocalCustomTexture]
function BaseInitSystem.ApplyLocalCustomTexture(folderFullName) end
---@instance
---@function [BaseInitSystem.IsInvoking]
function BaseInitSystem.IsInvoking() end
---@instance
---@function [BaseInitSystem.CancelInvoke]
function BaseInitSystem.CancelInvoke() end
---@instance
---@function [BaseInitSystem.Invoke]
function BaseInitSystem.Invoke(methodName, time) end
---@instance
---@function [BaseInitSystem.InvokeRepeating]
function BaseInitSystem.InvokeRepeating(methodName, time, repeatRate) end
---@instance
---@function [BaseInitSystem.CancelInvoke]
function BaseInitSystem.CancelInvoke(methodName) end
---@instance
---@function [BaseInitSystem.IsInvoking]
function BaseInitSystem.IsInvoking(methodName) end
---@instance
---@function [BaseInitSystem.StartCoroutine]
function BaseInitSystem.StartCoroutine(methodName) end
---@instance
---@function [BaseInitSystem.StartCoroutine]
function BaseInitSystem.StartCoroutine(methodName, value) end
---@instance
---@function [BaseInitSystem.StartCoroutine]
function BaseInitSystem.StartCoroutine(routine) end
---@instance
---@function [BaseInitSystem.StartCoroutine_Auto]
function BaseInitSystem.StartCoroutine_Auto(routine) end
---@instance
---@function [BaseInitSystem.StopCoroutine]
function BaseInitSystem.StopCoroutine(routine) end
---@instance
---@function [BaseInitSystem.StopCoroutine]
function BaseInitSystem.StopCoroutine(routine) end
---@instance
---@function [BaseInitSystem.StopCoroutine]
function BaseInitSystem.StopCoroutine(methodName) end
---@instance
---@function [BaseInitSystem.StopAllCoroutines]
function BaseInitSystem.StopAllCoroutines() end
---@instance
---@function [BaseInitSystem.get_useGUILayout]
function BaseInitSystem.get_useGUILayout() end
---@instance
---@function [BaseInitSystem.set_useGUILayout]
function BaseInitSystem.set_useGUILayout(value) end
---@instance
---@function [BaseInitSystem.get_runInEditMode]
function BaseInitSystem.get_runInEditMode() end
---@instance
---@function [BaseInitSystem.set_runInEditMode]
function BaseInitSystem.set_runInEditMode(value) end
---@instance
---@function [BaseInitSystem.get_enabled]
function BaseInitSystem.get_enabled() end
---@instance
---@function [BaseInitSystem.set_enabled]
function BaseInitSystem.set_enabled(value) end
---@instance
---@function [BaseInitSystem.get_isActiveAndEnabled]
function BaseInitSystem.get_isActiveAndEnabled() end
---@instance
---@function [BaseInitSystem.get_transform]
function BaseInitSystem.get_transform() end
---@instance
---@function [BaseInitSystem.get_gameObject]
function BaseInitSystem.get_gameObject() end
---@instance
---@function [BaseInitSystem.GetComponent]
function BaseInitSystem.GetComponent(type) end
---@instance
---@function [BaseInitSystem.GetComponent]
function BaseInitSystem.GetComponent() end
---@instance
---@function [BaseInitSystem.TryGetComponent]
function BaseInitSystem.TryGetComponent(type, component) end
---@instance
---@function [BaseInitSystem.TryGetComponent]
function BaseInitSystem.TryGetComponent(component) end
---@instance
---@function [BaseInitSystem.GetComponent]
function BaseInitSystem.GetComponent(type) end
---@instance
---@function [BaseInitSystem.GetComponentInChildren]
function BaseInitSystem.GetComponentInChildren(t, includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentInChildren]
function BaseInitSystem.GetComponentInChildren(t) end
---@instance
---@function [BaseInitSystem.GetComponentInChildren]
function BaseInitSystem.GetComponentInChildren(includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentInChildren]
function BaseInitSystem.GetComponentInChildren() end
---@instance
---@function [BaseInitSystem.GetComponentsInChildren]
function BaseInitSystem.GetComponentsInChildren(t, includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentsInChildren]
function BaseInitSystem.GetComponentsInChildren(t) end
---@instance
---@function [BaseInitSystem.GetComponentsInChildren]
function BaseInitSystem.GetComponentsInChildren(includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentsInChildren]
function BaseInitSystem.GetComponentsInChildren(includeInactive, result) end
---@instance
---@function [BaseInitSystem.GetComponentsInChildren]
function BaseInitSystem.GetComponentsInChildren() end
---@instance
---@function [BaseInitSystem.GetComponentsInChildren]
function BaseInitSystem.GetComponentsInChildren(results) end
---@instance
---@function [BaseInitSystem.GetComponentInParent]
function BaseInitSystem.GetComponentInParent(t, includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentInParent]
function BaseInitSystem.GetComponentInParent(t) end
---@instance
---@function [BaseInitSystem.GetComponentInParent]
function BaseInitSystem.GetComponentInParent(includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentInParent]
function BaseInitSystem.GetComponentInParent() end
---@instance
---@function [BaseInitSystem.GetComponentsInParent]
function BaseInitSystem.GetComponentsInParent(t, includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentsInParent]
function BaseInitSystem.GetComponentsInParent(t) end
---@instance
---@function [BaseInitSystem.GetComponentsInParent]
function BaseInitSystem.GetComponentsInParent(includeInactive) end
---@instance
---@function [BaseInitSystem.GetComponentsInParent]
function BaseInitSystem.GetComponentsInParent(includeInactive, results) end
---@instance
---@function [BaseInitSystem.GetComponentsInParent]
function BaseInitSystem.GetComponentsInParent() end
---@instance
---@function [BaseInitSystem.GetComponents]
function BaseInitSystem.GetComponents(type) end
---@instance
---@function [BaseInitSystem.GetComponents]
function BaseInitSystem.GetComponents(type, results) end
---@instance
---@function [BaseInitSystem.GetComponents]
function BaseInitSystem.GetComponents(results) end
---@instance
---@function [BaseInitSystem.get_tag]
function BaseInitSystem.get_tag() end
---@instance
---@function [BaseInitSystem.set_tag]
function BaseInitSystem.set_tag(value) end
---@instance
---@function [BaseInitSystem.GetComponents]
function BaseInitSystem.GetComponents() end
---@instance
---@function [BaseInitSystem.CompareTag]
function BaseInitSystem.CompareTag(tag) end
---@instance
---@function [BaseInitSystem.SendMessageUpwards]
function BaseInitSystem.SendMessageUpwards(methodName, value, options) end
---@instance
---@function [BaseInitSystem.SendMessageUpwards]
function BaseInitSystem.SendMessageUpwards(methodName, value) end
---@instance
---@function [BaseInitSystem.SendMessageUpwards]
function BaseInitSystem.SendMessageUpwards(methodName) end
---@instance
---@function [BaseInitSystem.SendMessageUpwards]
function BaseInitSystem.SendMessageUpwards(methodName, options) end
---@instance
---@function [BaseInitSystem.SendMessage]
function BaseInitSystem.SendMessage(methodName, value) end
---@instance
---@function [BaseInitSystem.SendMessage]
function BaseInitSystem.SendMessage(methodName) end
---@instance
---@function [BaseInitSystem.SendMessage]
function BaseInitSystem.SendMessage(methodName, value, options) end
---@instance
---@function [BaseInitSystem.SendMessage]
function BaseInitSystem.SendMessage(methodName, options) end
---@instance
---@function [BaseInitSystem.BroadcastMessage]
function BaseInitSystem.BroadcastMessage(methodName, parameter, options) end
---@instance
---@function [BaseInitSystem.BroadcastMessage]
function BaseInitSystem.BroadcastMessage(methodName, parameter) end
---@instance
---@function [BaseInitSystem.BroadcastMessage]
function BaseInitSystem.BroadcastMessage(methodName) end
---@instance
---@function [BaseInitSystem.BroadcastMessage]
function BaseInitSystem.BroadcastMessage(methodName, options) end
---@instance
---@function [BaseInitSystem.get_rigidbody]
function BaseInitSystem.get_rigidbody() end
---@instance
---@function [BaseInitSystem.get_rigidbody2D]
function BaseInitSystem.get_rigidbody2D() end
---@instance
---@function [BaseInitSystem.get_camera]
function BaseInitSystem.get_camera() end
---@instance
---@function [BaseInitSystem.get_light]
function BaseInitSystem.get_light() end
---@instance
---@function [BaseInitSystem.get_animation]
function BaseInitSystem.get_animation() end
---@instance
---@function [BaseInitSystem.get_constantForce]
function BaseInitSystem.get_constantForce() end
---@instance
---@function [BaseInitSystem.get_renderer]
function BaseInitSystem.get_renderer() end
---@instance
---@function [BaseInitSystem.get_audio]
function BaseInitSystem.get_audio() end
---@instance
---@function [BaseInitSystem.get_networkView]
function BaseInitSystem.get_networkView() end
---@instance
---@function [BaseInitSystem.get_collider]
function BaseInitSystem.get_collider() end
---@instance
---@function [BaseInitSystem.get_collider2D]
function BaseInitSystem.get_collider2D() end
---@instance
---@function [BaseInitSystem.get_hingeJoint]
function BaseInitSystem.get_hingeJoint() end
---@instance
---@function [BaseInitSystem.get_particleSystem]
function BaseInitSystem.get_particleSystem() end
---@instance
---@function [BaseInitSystem.GetInstanceID]
function BaseInitSystem.GetInstanceID() end
---@instance
---@function [BaseInitSystem.GetHashCode]
function BaseInitSystem.GetHashCode() end
---@instance
---@function [BaseInitSystem.Equals]
function BaseInitSystem.Equals(other) end
---@instance
---@function [BaseInitSystem.get_name]
function BaseInitSystem.get_name() end
---@instance
---@function [BaseInitSystem.set_name]
function BaseInitSystem.set_name(value) end
---@instance
---@function [BaseInitSystem.get_hideFlags]
function BaseInitSystem.get_hideFlags() end
---@instance
---@function [BaseInitSystem.set_hideFlags]
function BaseInitSystem.set_hideFlags(value) end
---@instance
---@function [BaseInitSystem.ToString]
function BaseInitSystem.ToString() end
---@instance
---@function [BaseInitSystem.GetType]
function BaseInitSystem.GetType() end
return BaseInitSystem

---@class ShanghaiWindy.Core.TeamManager
local TeamManager = {}

---@instance
---@function [TeamManager.Equals]
function TeamManager.Equals(obj) end
---@instance
---@function [TeamManager.GetHashCode]
function TeamManager.GetHashCode() end
---@instance
---@function [TeamManager.GetType]
function TeamManager.GetType() end
---@instance
---@function [TeamManager.ToString]
function TeamManager.ToString() end
return TeamManager

---@class ShanghaiWindy.Core.Lua.ILuaCommonMod
local ILuaCommonMod = {}

---@instance
---@function [ILuaCommonMod.OnStarted]
function ILuaCommonMod.OnStarted() end
---@instance
---@function [ILuaCommonMod.OnUpdated]
function ILuaCommonMod.OnUpdated() end
---@instance
---@function [ILuaCommonMod.OnFixedUpdated]
function ILuaCommonMod.OnFixedUpdated() end
---@instance
---@function [ILuaCommonMod.OnGUI]
function ILuaCommonMod.OnGUI() end
---@instance
---@function [ILuaCommonMod.OnLateUpdated]
function ILuaCommonMod.OnLateUpdated() end
---@instance
---@function [ILuaCommonMod.OnSceneLoaded]
function ILuaCommonMod.OnSceneLoaded(levelName) end
return ILuaCommonMod

---@class ShanghaiWindy.Core.Lua.ILuaGameModeMod
local ILuaGameModeMod = {}

---@instance
---@function [ILuaGameModeMod.GetModeName]
function ILuaGameModeMod.GetModeName(lang) end
---@instance
---@function [ILuaGameModeMod.OnStartMode]
function ILuaGameModeMod.OnStartMode() end
---@instance
---@function [ILuaGameModeMod.OnExitMode]
function ILuaGameModeMod.OnExitMode() end
---@instance
---@function [ILuaGameModeMod.IsProxyBattle]
function ILuaGameModeMod.IsProxyBattle() end
return ILuaGameModeMod

---@class ShanghaiWindy.Core.Lua.ILuaMod
local ILuaMod = {}

---@instance
---@function [ILuaMod.GetModName]
function ILuaMod.GetModName() end
---@instance
---@function [ILuaMod.GetAuthor]
function ILuaMod.GetAuthor() end
---@instance
---@function [ILuaMod.GetDescription]
function ILuaMod.GetDescription() end
return ILuaMod

---@class ShanghaiWindy.Core.Data.BulletFiredInfo
local BulletFiredInfo = {}

---@instance
---@function [BulletFiredInfo.Equals]
function BulletFiredInfo.Equals(obj) end
---@instance
---@function [BulletFiredInfo.GetHashCode]
function BulletFiredInfo.GetHashCode() end
---@instance
---@function [BulletFiredInfo.ToString]
function BulletFiredInfo.ToString() end
---@instance
---@function [BulletFiredInfo.GetType]
function BulletFiredInfo.GetType() end
return BulletFiredInfo

---@class ShanghaiWindy.Core.API.SpawnVehicleAPI
local SpawnVehicleAPI = {}

---@static
---@function [SpawnVehicleAPI.CreateLocalBot]
function SpawnVehicleAPI.CreateLocalBot(vehicleInfo, pos, rot, botTeam, isKeepWreckage, isIdle) end
---@static
---@function [SpawnVehicleAPI.CreatePlayer]
function SpawnVehicleAPI.CreatePlayer(vehicleInfo, pos, rot, onPreBind) end
---@static
---@function [SpawnVehicleAPI.CreateFreeCamera]
function SpawnVehicleAPI.CreateFreeCamera(pos, rot) end
---@instance
---@function [SpawnVehicleAPI.Equals]
function SpawnVehicleAPI.Equals(obj) end
---@instance
---@function [SpawnVehicleAPI.GetHashCode]
function SpawnVehicleAPI.GetHashCode() end
---@instance
---@function [SpawnVehicleAPI.GetType]
function SpawnVehicleAPI.GetType() end
---@instance
---@function [SpawnVehicleAPI.ToString]
function SpawnVehicleAPI.ToString() end
return SpawnVehicleAPI

---@class ShanghaiWindy.Core.API.OnVehicleLoadedDelegate
local OnVehicleLoadedDelegate = {}

---@instance
---@function [OnVehicleLoadedDelegate.Invoke]
function OnVehicleLoadedDelegate.Invoke() end
---@instance
---@function [OnVehicleLoadedDelegate.BeginInvoke]
function OnVehicleLoadedDelegate.BeginInvoke(callback, object) end
---@instance
---@function [OnVehicleLoadedDelegate.EndInvoke]
function OnVehicleLoadedDelegate.EndInvoke(result) end
---@instance
---@function [OnVehicleLoadedDelegate.GetObjectData]
function OnVehicleLoadedDelegate.GetObjectData(info, context) end
---@instance
---@function [OnVehicleLoadedDelegate.Equals]
function OnVehicleLoadedDelegate.Equals(obj) end
---@instance
---@function [OnVehicleLoadedDelegate.GetHashCode]
function OnVehicleLoadedDelegate.GetHashCode() end
---@instance
---@function [OnVehicleLoadedDelegate.GetInvocationList]
function OnVehicleLoadedDelegate.GetInvocationList() end
---@instance
---@function [OnVehicleLoadedDelegate.get_Method]
function OnVehicleLoadedDelegate.get_Method() end
---@instance
---@function [OnVehicleLoadedDelegate.get_Target]
function OnVehicleLoadedDelegate.get_Target() end
---@instance
---@function [OnVehicleLoadedDelegate.DynamicInvoke]
function OnVehicleLoadedDelegate.DynamicInvoke(args) end
---@instance
---@function [OnVehicleLoadedDelegate.Clone]
function OnVehicleLoadedDelegate.Clone() end
---@instance
---@function [OnVehicleLoadedDelegate.GetType]
function OnVehicleLoadedDelegate.GetType() end
---@instance
---@function [OnVehicleLoadedDelegate.ToString]
function OnVehicleLoadedDelegate.ToString() end
return OnVehicleLoadedDelegate

---@class ShanghaiWindy.Core.API.OnVehicleDestroyedDelegate
local OnVehicleDestroyedDelegate = {}

---@instance
---@function [OnVehicleDestroyedDelegate.Invoke]
function OnVehicleDestroyedDelegate.Invoke() end
---@instance
---@function [OnVehicleDestroyedDelegate.BeginInvoke]
function OnVehicleDestroyedDelegate.BeginInvoke(callback, object) end
---@instance
---@function [OnVehicleDestroyedDelegate.EndInvoke]
function OnVehicleDestroyedDelegate.EndInvoke(result) end
---@instance
---@function [OnVehicleDestroyedDelegate.GetObjectData]
function OnVehicleDestroyedDelegate.GetObjectData(info, context) end
---@instance
---@function [OnVehicleDestroyedDelegate.Equals]
function OnVehicleDestroyedDelegate.Equals(obj) end
---@instance
---@function [OnVehicleDestroyedDelegate.GetHashCode]
function OnVehicleDestroyedDelegate.GetHashCode() end
---@instance
---@function [OnVehicleDestroyedDelegate.GetInvocationList]
function OnVehicleDestroyedDelegate.GetInvocationList() end
---@instance
---@function [OnVehicleDestroyedDelegate.get_Method]
function OnVehicleDestroyedDelegate.get_Method() end
---@instance
---@function [OnVehicleDestroyedDelegate.get_Target]
function OnVehicleDestroyedDelegate.get_Target() end
---@instance
---@function [OnVehicleDestroyedDelegate.DynamicInvoke]
function OnVehicleDestroyedDelegate.DynamicInvoke(args) end
---@instance
---@function [OnVehicleDestroyedDelegate.Clone]
function OnVehicleDestroyedDelegate.Clone() end
---@instance
---@function [OnVehicleDestroyedDelegate.GetType]
function OnVehicleDestroyedDelegate.GetType() end
---@instance
---@function [OnVehicleDestroyedDelegate.ToString]
function OnVehicleDestroyedDelegate.ToString() end
return OnVehicleDestroyedDelegate

---@class ShanghaiWindy.Core.API.OnVehicleRemovedDelegate
local OnVehicleRemovedDelegate = {}

---@instance
---@function [OnVehicleRemovedDelegate.Invoke]
function OnVehicleRemovedDelegate.Invoke() end
---@instance
---@function [OnVehicleRemovedDelegate.BeginInvoke]
function OnVehicleRemovedDelegate.BeginInvoke(callback, object) end
---@instance
---@function [OnVehicleRemovedDelegate.EndInvoke]
function OnVehicleRemovedDelegate.EndInvoke(result) end
---@instance
---@function [OnVehicleRemovedDelegate.GetObjectData]
function OnVehicleRemovedDelegate.GetObjectData(info, context) end
---@instance
---@function [OnVehicleRemovedDelegate.Equals]
function OnVehicleRemovedDelegate.Equals(obj) end
---@instance
---@function [OnVehicleRemovedDelegate.GetHashCode]
function OnVehicleRemovedDelegate.GetHashCode() end
---@instance
---@function [OnVehicleRemovedDelegate.GetInvocationList]
function OnVehicleRemovedDelegate.GetInvocationList() end
---@instance
---@function [OnVehicleRemovedDelegate.get_Method]
function OnVehicleRemovedDelegate.get_Method() end
---@instance
---@function [OnVehicleRemovedDelegate.get_Target]
function OnVehicleRemovedDelegate.get_Target() end
---@instance
---@function [OnVehicleRemovedDelegate.DynamicInvoke]
function OnVehicleRemovedDelegate.DynamicInvoke(args) end
---@instance
---@function [OnVehicleRemovedDelegate.Clone]
function OnVehicleRemovedDelegate.Clone() end
---@instance
---@function [OnVehicleRemovedDelegate.GetType]
function OnVehicleRemovedDelegate.GetType() end
---@instance
---@function [OnVehicleRemovedDelegate.ToString]
function OnVehicleRemovedDelegate.ToString() end
return OnVehicleRemovedDelegate

---@class ShanghaiWindy.Core.API.OnFiredDelegate
local OnFiredDelegate = {}

---@instance
---@function [OnFiredDelegate.Invoke]
function OnFiredDelegate.Invoke(bulletFiredInfo) end
---@instance
---@function [OnFiredDelegate.BeginInvoke]
function OnFiredDelegate.BeginInvoke(bulletFiredInfo, callback, object) end
---@instance
---@function [OnFiredDelegate.EndInvoke]
function OnFiredDelegate.EndInvoke(result) end
---@instance
---@function [OnFiredDelegate.GetObjectData]
function OnFiredDelegate.GetObjectData(info, context) end
---@instance
---@function [OnFiredDelegate.Equals]
function OnFiredDelegate.Equals(obj) end
---@instance
---@function [OnFiredDelegate.GetHashCode]
function OnFiredDelegate.GetHashCode() end
---@instance
---@function [OnFiredDelegate.GetInvocationList]
function OnFiredDelegate.GetInvocationList() end
---@instance
---@function [OnFiredDelegate.get_Method]
function OnFiredDelegate.get_Method() end
---@instance
---@function [OnFiredDelegate.get_Target]
function OnFiredDelegate.get_Target() end
---@instance
---@function [OnFiredDelegate.DynamicInvoke]
function OnFiredDelegate.DynamicInvoke(args) end
---@instance
---@function [OnFiredDelegate.Clone]
function OnFiredDelegate.Clone() end
---@instance
---@function [OnFiredDelegate.GetType]
function OnFiredDelegate.GetType() end
---@instance
---@function [OnFiredDelegate.ToString]
function OnFiredDelegate.ToString() end
return OnFiredDelegate

---@class ShanghaiWindy.Core.API.VehicleAPI
local VehicleAPI = {}

---@static
---@function [VehicleAPI.RegisterVehicleLoadedEvent]
function VehicleAPI.RegisterVehicleLoadedEvent(vehicle, vehicleLoadedDelegate) end
---@static
---@function [VehicleAPI.UnRegisterVehicleLoaedEvent]
function VehicleAPI.UnRegisterVehicleLoaedEvent(vehicle, vehicleLoadedDelegate) end
---@static
---@function [VehicleAPI.RegisterVehicleDestroyedEvent]
function VehicleAPI.RegisterVehicleDestroyedEvent(vehicle, vehicleDestroyedDelegate) end
---@static
---@function [VehicleAPI.UnRegisterVehicleDestroyedEvent]
function VehicleAPI.UnRegisterVehicleDestroyedEvent(vehicle, vehicleDestroyedDelegate) end
---@static
---@function [VehicleAPI.RegisterVehicleGameObjectDestroyedEvent]
function VehicleAPI.RegisterVehicleGameObjectDestroyedEvent(vehicle, vehicleGameObjectDestroyed) end
---@static
---@function [VehicleAPI.UnRegisterVehicleGameObjectDestroyedEvent]
function VehicleAPI.UnRegisterVehicleGameObjectDestroyedEvent(vehicle, vehicleGameObjectDestroyed) end
---@static
---@function [VehicleAPI.RegisterBulletFiredEvent]
function VehicleAPI.RegisterBulletFiredEvent(vehicle, index, tankFiredDelegate) end
---@static
---@function [VehicleAPI.UnRegisterBulletFiredEvent]
function VehicleAPI.UnRegisterBulletFiredEvent(vehicle, index, tankFiredDelegate) end
---@static
---@function [VehicleAPI.GetPlayerVehicle]
function VehicleAPI.GetPlayerVehicle() end
---@static
---@function [VehicleAPI.TryGetTankInitSystem]
function VehicleAPI.TryGetTankInitSystem(gameObject, tankInitSystem) end
---@static
---@function [VehicleAPI.TryGetFlightInitSystem]
function VehicleAPI.TryGetFlightInitSystem(gameObject, flightInitSystem) end
---@static
---@function [VehicleAPI.TryGetArmyInitSystem]
function VehicleAPI.TryGetArmyInitSystem(gameObject, armyInitSystem) end
---@static
---@function [VehicleAPI.GetFireList]
function VehicleAPI.GetFireList(vehicle) end
---@instance
---@function [VehicleAPI.Equals]
function VehicleAPI.Equals(obj) end
---@instance
---@function [VehicleAPI.GetHashCode]
function VehicleAPI.GetHashCode() end
---@instance
---@function [VehicleAPI.GetType]
function VehicleAPI.GetType() end
---@instance
---@function [VehicleAPI.ToString]
function VehicleAPI.ToString() end
return VehicleAPI

