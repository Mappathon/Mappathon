void createInterface() {

  PFont font = createFont("arial", 16);
  cp5 = new ControlP5(this);
  cp5.addTextfield("tag1")
    .setPosition(110, 10)
      .setSize(200, 25)
        .setFont(font)
          .setFocus(true)
            .setColor(color(255, 255, 255))
              ;

  /*
  swapKnob = cp5.addKnob("speed")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(350, 10)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  */

  // 1
  swapKnobs[0] = cp5.addKnob("speed1")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(250, 250)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 2
  swapKnobs[1] = cp5.addKnob("speed2")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(556, 250)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 3
  swapKnobs[2] = cp5.addKnob("speed3")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(862, 250)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 4
  swapKnobs[3] = cp5.addKnob("speed4")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(1168, 250)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 5
  swapKnobs[4] = cp5.addKnob("speed5")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(250, 556)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 6
  swapKnobs[5] = cp5.addKnob("speed6")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(556, 556)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 7
  swapKnobs[6] = cp5.addKnob("speed7")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(862, 556)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
  // 8
  swapKnobs[7] = cp5.addKnob("speed8")
    .setRange(0, 10)
      .setValue(3)
        .setPosition(1168, 556)
          .setRadius(15)
            .setNumberOfTickMarks(10)
              .setTickMarkLength(2)
                .snapToTickMarks(true)
                  .setColorForeground(color(255))
                    .setDragDirection(Knob.HORIZONTAL)
                      ;
                      
}

