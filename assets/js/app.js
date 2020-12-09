// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"
import "../css/app.scss"
import "../node_modules/material-design-lite/material.min.css"
import "../node_modules/material-design-lite/material.min.js"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import Sortable from "sortablejs";


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket




let Hooks = {}

Hooks.DragNDrop = {
  mounted() {
    console.log('drag and drop')
    const sortCallback = (event) => {
      const chosen_players = document.querySelectorAll(".chosen_player")
      const playerObjects = [...chosen_players].map((player, index) => {
        return {
          id: player.dataset.playerId,
          index: index
        }
      })

      this.pushEvent("sort", {
        oldIndex: event.oldIndex,
        newIndex: event.newIndex,
        playerId: event.item.dataset['playerId'],
        toId: event.to.id,
        fromId: event.from.id,
        type: event.type,
        playerOrder: playerObjects
      });
    };

    const addCallback = (event, classToAdd) => {
      var itemEl = event.item;
      itemEl.classList.add(classToAdd)

      const chosen_players = document.querySelectorAll(".chosen_player")
      const playerObjects = [...chosen_players].map((player, index) => {
        return {
          id: player.dataset.playerId,
          index: index
        }
      })

      this.pushEvent("add", {
        oldIndex: event.oldIndex,
        newIndex: event.newIndex,
        playerId: event.item.dataset['playerId'],
        toId: event.to.id,
        fromId: event.from.id,
        type: event.type,
        playerOrder: playerObjects
      });
    };

    const chosenArea = document.querySelector('.chosen_players')
    const chosenSortable = Sortable.create(chosenArea, {
      draggable: '.player',
      dragClass: 'bg-white',
      group: 'players',
      onAdd: function (event) {
        addCallback(event, 'chosen_player')
      },
      onSort: function (event) {
        sortCallback(event)
      },
    });

    const unusedArea = document.querySelector('.unused_players')
    const unusedSortable = Sortable.create(unusedArea, {
      draggable: '.player',
      group: 'players',
      dragClass: 'bg-white',
      onAdd: function (event) {
        addCallback(event, 'unchosen_player')
      },
      onSort: function (event) {
        sortCallback(event)
      },
    });
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Connect if there are any LiveViews on the page
liveSocket.connect()
