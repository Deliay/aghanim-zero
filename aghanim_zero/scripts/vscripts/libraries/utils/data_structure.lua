Queue = {}

function Queue.new()
    return {first = 0, last = -1}
end

function Queue.pushFront(list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end

function Queue.pushBack(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end

function Queue.empty(list)
    return list.first > list.last
end

function Queue.length(list)
    return list.last - list.first
end

function Queue.popFront(list)
    local first = list.first
    if first > list.last then
        error("Queue is empty")
    end
    local value = list[first]
    list[first] = nil
    list.first = first + 1
    return value
end

function Queue.popBack(list)
    local last = list.last
    if list.first > last then
        error("Queue is empty")
    end
    local value = list[last]
    list[last] = nil
    list.last = last - 1
    return value
end
