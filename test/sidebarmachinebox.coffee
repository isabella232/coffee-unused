kd                      = require 'kd'
remote                  = require('app/remote').getInstance()
KDView                  = kd.View
KDListViewController    = kd.ListViewController
KDCustomHTMLView        = kd.CustomHTMLView
Machine                 = require 'app/providers/machine'
NavigationMachineItem   = require 'app/navigation/navigationmachineitem'
SidebarWorkspaceItem    = require './sidebarworkspaceitem'
MoreWorkspacesModal     = require 'app/activity/sidebar/moreworkspacesmodal'
AddWorkspaceView        = require 'app/addworkspaceview'
environmentDataProvider = require 'app/userenvironmentdataprovider'
isKoding                = require 'app/util/isKoding'


module.exports = class SidebarMachineBox extends KDView

  constructor: (options = {}, data) ->

    options.cssClass = "sidebar-machine-box #{data.machine.label}"

    super options, data

    @machine = data.machine

    unless @machine instanceof Machine
      @machine = new Machine machine: remote.revive data.machine

    @workspaceListItemsById = {}

    @createMachineItem()

    @createWorkspacesLabel()
    @createWorkspacesList()
    @watchMachineState()

    @machine.on 'MachineLabelUpdated', @bound 'handleMachineLabelUpdated'

    computeController = kd.getSingleton 'computeController'
    computeController.on "stateChanged-#{@machine._id}", @bound 'handleStateChanged'

    if stack = computeController.findStackFromMachineId @machine._id
      visibility = stack.config?.sidebar?[@machine.uid]?.visibility

    @setVisibility visibility ? on


  handleStateChanged: (state) ->

    if state is Machine.State.Running
      kd.singletons.mainView.sidebar.emit 'ShowCloseHandle'
      @machineItem.settingsIcon.show()

