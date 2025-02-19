/*
    OpenSCAD 7 Segment Library
    --------------------------
    
    To use this module, place "use <7seg.lib.scad>" in your code.
    Then call digit_outline() etc., see examples.
    
    Parameters are as follows:
    
    width:
        Width of the display at 0 degrees skew (only inner part, outline is excluded)
    height:
        Height of the display (only inner part, outline is excluded)
    thickness:
        Width of each segment itself (only inner part, outline is excluded)
    spacing:
        Spacing between the segments, this also defines the thickness of the outline
    depth:
        Depth (z direction) of the display. Set to 0 for 2D modules!
    skew:
        Skew (to right) of the display. This will increase the overall width!
    edge:
        Fraction between 0 and 1 for "cut" edges. 0 will give sharp edges
    segments:
        Array of segments to create. e.g. [1,2,3,5] will draw a "4"

*/

// Example preview:
translate([-80,0,0]) color("red")
    digit_hull(60,100,12,1,10,5,1);
    
translate([-00,0,0]) color("green")
    digit_inner(60,100,12,1,10,0,1);
    
translate([+80,0,0]) color("blue") 
    digit_outline(60,100,12,1,10,-5,1,[1,2,3,5]);



module digit_outline(width,height,thickness,spacing,depth=10,skew=0,edge=1,segments=[0:6],nice=1) {
    for(segment=segments) {
        segment_outline(width,height,thickness,spacing,depth,skew,edge,segment,nice);
    }
}

module digit_inner(width,height,thickness,spacing,depth=10,skew=0,edge=1,segments=[0:6],nice=1) {
    for(segment=segments) {
        segment_inner(width,height,thickness,spacing,depth,skew,edge,segment,nice);
    }
}


module digit_hull(width,height,thickness,spacing,depth=10,skew=0,edge=1,segments=[0:6],nice=1) {
    for(segment=segments) {
        segment_hull(width,height,thickness,spacing,depth,skew,edge,segment,nice);
    }
}



module segment_inner(width,height,thickness,spacing,depth,skew,edge,segment,nice) {
    __add_depth(depth) difference() {
        hull() segment_outline(width,height,thickness,spacing,0,skew,edge,segment,nice);
        segment_outline(width,height,thickness,spacing,0,skew,edge,segment,nice);
    }
}


module segment_hull(width,height,thickness,spacing,depth,skew,edge,segment,nice) {
    __add_depth(depth) hull() segment_outline(width,height,thickness,spacing,0,skew,edge,segment,nice);
}


module segment_outline(width,height,thickness,spacing,depth,skew,edge,segment,nice) {
    n = [
        [0,1],[1,3],[3,6],[6,5],[5,2],[2,0],
        [3,7],[7,11],[11,13],[13,10],[10,6],[6,3],
        [2,5],[5,9],[9,12],[12,8],[8,4],[4,2],
        [9,10],[10,13],[13,16],[16,15],[15,12],[12,9],
        [12,15],[15,19],[19,22],[22,18],[18,14],[14,12],
        [13,17],[17,21],[21,23],[23,20],[20,16],[16,13],
        [19,20],[20,23],[23,25],[25,24],[24,22],[22,19],
    ];
    __add_depth(depth) for(i=[0:5]) hull() {
        translate(segment_point(width,height,thickness,spacing,skew,edge,n[segment*6+i][0],nice)) circle(r=spacing/2,$fn=24);
        translate(segment_point(width,height,thickness,spacing,skew,edge,n[segment*6+i][1],nice)) circle(r=spacing/2,$fn=24);
    }
}

function segment_point(width,height,thickness,spacing,skew,edge,i,nice) =
    let(sx = width/2 + spacing/2,
    sy = height/2 + spacing/2,
    ss = thickness+spacing,
    st = ss*edge,
    
    bp = [
        [sx-ss/2, 0], // 13 - 0
        [sx-ss, ss/2], // 10 - 1
        [sx, ss/2], // 11 - 2
        [sx-ss, sy-ss], // 6 - 3
        [sx, sy-st], // 7 - 4
        [sx-st,sy], // 1 - 5
        [sx-st/2,sy-st/2] // 3 - 6
    ],

    p = [
        [-bp[5][0]-nice*thickness/3, bp[5][1]], // top top left
        [ bp[5][0]+nice*thickness/3, bp[5][1]], // top top right
        [-bp[6][0]-nice*thickness/6, bp[6][1]+nice*thickness/6], // top left outer contact
        [ bp[6][0]+nice*thickness/6, bp[6][1]+nice*thickness/6], // top right outer contact
        [-bp[4][0], bp[4][1]+nice*thickness/3], // top left left
        [-bp[3][0], bp[3][1]], // top left inner contact
        [ bp[3][0], bp[3][1]], // top right inner contact
        [ bp[4][0], bp[4][1]+nice*thickness/3], // top right right
        [-bp[2][0], bp[2][1]], // center left upper outer
        [-bp[1][0], bp[1][1]], // center left upper inner
        [ bp[1][0], bp[1][1]], // center right upper inner
        [ bp[2][0], bp[2][1]], // center right upper outer
        [-bp[0][0], bp[0][1]], // 12 -thickness/6 center left contact
        [ bp[0][0], bp[0][1]], // +thickness/6 center right contact
        [-bp[2][0],-bp[2][1]], // center left lower outer
        [-bp[1][0],-bp[1][1]], // center left lower inner
        [ bp[1][0],-bp[1][1]], // center right lower inner
        [ bp[2][0],-bp[2][1]], // center right lower outer
        [-bp[4][0],-bp[4][1]-nice*thickness/3], // bottom left left
        [-bp[3][0],-bp[3][1]], // bottom left inner contact
        [ bp[3][0],-bp[3][1]], // bottom right inner contact
        [ bp[4][0],-bp[4][1]-nice*thickness/3], // bottom right right
        [-bp[6][0]-nice*thickness/6,-bp[6][1]-nice*thickness/6], // bottom left outer contact
        [ bp[6][0]+nice*thickness/6,-bp[6][1]-nice*thickness/6], // bottom right outer contact
        [-bp[5][0]-nice*thickness/3,-bp[5][1]], // bottom bottom left
        [ bp[5][0]+nice*thickness/3,-bp[5][1]], // bottom bottom right
    ] * [
    [1,0],
    [tan(skew),1]
    ])
      p[i];

module __add_depth(depth) {
    if(depth > 0) {
        linear_extrude(depth) children();
    } else {
        children();
    }
}