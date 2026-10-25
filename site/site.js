/* Conservatio, conservatio.peterdsp.dev
   The page's one live thing: the loupe. It reads the pointer off a real
   photograph of a wall painting and prints the position at the report's own
   1:2 scale, and the recorded observation nearest the pointer.
   The page reads correctly with this file absent. */
(function () {
  'use strict';
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------------- the loupe ---------------- */
  (function () {
    var box = document.getElementById('loupe');
    if (!box) return;
    var xh = document.getElementById('xhair');
    var vx = xh.querySelector('.vx'), hz = xh.querySelector('.hz');
    var marks = [].slice.call(box.querySelectorAll('.mark'));
    var rType = document.getElementById('rType'), rSev = document.getElementById('rSev');
    var rArea = document.getElementById('rArea'), rPos = document.getElementById('rPos');

    // The object is 145 x 210 cm (the report's own dimensions); the readout
    // states the position on the object, halved for the 1:2 plate scale.
    var OBJ_W = 145, OBJ_H = 210;

    function select(m) {
      marks.forEach(function (o) { o.setAttribute('aria-pressed', String(o === m)); });
      rType.textContent = m.dataset.type;
      rSev.textContent = m.dataset.sev;
      rArea.textContent = m.dataset.area + ' m²';
    }
    marks.forEach(function (m) {
      m.addEventListener('click', function (e) { e.preventDefault(); select(m); });
    });

    function read(e) {
      var r = box.getBoundingClientRect();
      var px = ((e.clientX - r.left) / r.width);
      var py = ((e.clientY - r.top) / r.height);
      if (px < 0 || px > 1 || py < 0 || py > 1) return;
      vx.style.left = (px * 100) + '%';
      hz.style.top = (py * 100) + '%';
      rPos.textContent = (px * OBJ_W / 2).toFixed(1) + ' × ' + (py * OBJ_H / 2).toFixed(1) + ' cm';
      // name the nearest recorded observation
      var best = null, bd = Infinity;
      marks.forEach(function (m) {
        var dx = parseFloat(m.style.left) / 100 - px, dy = parseFloat(m.style.top) / 100 - py;
        var d = dx * dx + dy * dy;
        if (d < bd) { bd = d; best = m; }
      });
      if (best && bd < 0.045) select(best);
    }
    box.addEventListener('pointermove', read);
    box.addEventListener('pointerdown', read);
    box.addEventListener('pointerleave', function () { rPos.textContent = 'tap or move across'; });
  })();

  /* ------------- the middle copy is live: it completes the observation ------------- */
  (function () {
    var add = document.getElementById('aAdd');
    if (!add) return;
    var count = document.getElementById('aCount');
    var note = document.getElementById('aNote'), noteV = document.getElementById('aNoteV');
    var done = false;
    add.addEventListener('click', function () {
      done = !done;
      count.textContent = done ? '2 observations' : '1 observation';
      note.textContent = done ? 'Recorded by' : 'Note';
      noteV.textContent = done ? 'E. Papadopoulou, today' : 'detachment risk along upper layer';
      add.textContent = done ? 'Undo' : 'Record the observation';
    });
  })();

  /* ---------------- entrances ---------------- */
  (function () {
    var targets = document.querySelectorAll('section, .plate .note, .rows, .slip, figure');
    if (!('IntersectionObserver' in window) || reduce) {
      for (var i = 0; i < targets.length; i++) targets[i].classList.add('in');
      return;
    }
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0.06 });
    for (var k = 0; k < targets.length; k++) io.observe(targets[k]);
    requestAnimationFrame(function () {
      var h = document.querySelector('.hero');
      if (h) h.classList.add('in');
    });
  })();
})();
