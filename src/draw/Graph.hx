package draw;

import parsing.Node;
import util.Pair;

class Graph {
    public var nodes:List<NodePos>;
    public var cons:List<Connection>;
    public var links:List<Link>;

    public inline function new(l:List<Node>) {
        // create objects
        nodes = new List<NodePos>();
        cons = new List<Connection>();
        links = new List<Link>();
        // fill out nodes
        for(e in l) {
            nodes.add(new NodePos(e));
        }
        // fill out connections/links
        for(node1 in nodes) {
            for(node2 in nodes) {
                if(node1.node.id > node2.node.id) {
                    // check if in cons
                    for(con in node2.node.cons) {
                        if(con.first == node1.node.id) {
                            cons.add(new Connection(node1, node2, con.second));
                            break;
                        }
                    }
                    // check if in links
                    for(con in node2.node.links) {
                        if(con.first == node1.node.id) {
                            links.add(new Link(node1, node2, con.second));
                            break;
                        }
                    }
                }
            }
        }
    }

    public inline function dist(x1:Float,y1:Float,x2:Float,y2:Float):Float {
        var dX:Float = x1 - x2;
        var dY:Float = y1 - y2;
        return Math.sqrt(dX*dX + dY*dY);
    }

    public inline function assignLinkPos():Void {
        // create a list with all the links that we need to assign
        var l:List<Link> = new List<Link>();
        for(link in links) {
            // remove maybe present older position data
            link.xPos = Math.NaN;
            link.yPos = Math.NaN;
            // calculate the two positions
            var vX:Float = link.n1.xPos - link.n2.xPos;
            var vY:Float = link.n1.yPos - link.n2.yPos;
            var vrX:Float = -vY / 4;
            var vrY:Float = vX / 4;
            var mX:Float = link.n2.xPos + vX / 2;
            var mY:Float = link.n2.yPos + vY / 2;
            link.x1 = mX - vrX;
            link.y1 = mY - vrY;
            link.x2 = mX + vrX;
            link.y2 = mY + vrY;
            // calculate the "energy" of the two positions
            link.e1 = 0;
            link.e2 = 0;
            for(node in nodes) {
                link.e1 += 1 / dist(node.xPos, node.yPos, link.x1, link.y1);
                link.e2 += 1 / dist(node.xPos, node.yPos, link.x2, link.y2);
            }
            // save
            l.add(link);
        }
        // assign positions
        while(!l.isEmpty()) {
            // get the best energy difference
            var bestEDiff:Float = -1.0;
            var bestLink:Link = null;
            for(link in l) {
                // calculate energy difference
                var eDiff:Float = Math.abs(link.e1 - link.e2);
                if(eDiff > bestEDiff) {
                    bestEDiff = eDiff;
                    bestLink = link;
                }
            }
            // assign best position
            bestLink.xPos = (bestLink.e1 < bestLink.e2) ? bestLink.x1 : bestLink.x2;
            bestLink.yPos = (bestLink.e1 < bestLink.e2) ? bestLink.y1 : bestLink.y2;
            // ok, create next list
            l.remove(bestLink);
        }
    }

    public inline function assignRandomNodePos():Void {
        for(node in nodes) {
            node.xPos = ((Math.random() > 0.5) ? -1 : 1) * 1000 * Math.random();
            node.yPos = ((Math.random() > 0.5) ? -1 : 1) * 1000 * Math.random();
        }
    }

    public inline function calculateEnergy():Float {
        var result:Float = 0;
        // energy of nodes
        for(node1 in nodes) {
            for(node2 in nodes) {
                if(node1.node.id > node2.node.id) {
                    result += 1.0 / dist(node1.xPos, node1.yPos, node2.xPos, node2.yPos);
                }
            }
        }
        // energy of connections
        for(con in cons) {
            var expDist:Float = con.n1.radius + con.n2.radius + con.l.length * 100;
            var rDist:Float = dist(con.n1.xPos, con.n1.yPos, con.n2.xPos, con.n2.yPos);
            var diff:Float = expDist - rDist;
            result += diff * diff;
        }
        return result;
    }
}