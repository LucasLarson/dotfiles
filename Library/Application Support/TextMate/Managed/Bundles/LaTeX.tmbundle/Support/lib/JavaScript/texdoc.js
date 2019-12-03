function dsp(loc) {
    if (document.getElementById) {
        foc = loc.parentNode.nextSibling.style ?
            loc.parentNode.nextSibling :
            loc.parentNode.nextSibling.nextSibling;
      foc.style.display = (foc.style.display=='block') ? 'none' : 'block';
  }
}
