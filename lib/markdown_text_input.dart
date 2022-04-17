import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';

/// Widget with markdown buttons
class MarkdownTextInput extends StatefulWidget {
  /// Callback called when text changed
  final void Function(String)? onChanged;

  /// Validator for the TextFormField
  final String? Function(String? value)? validators;

  /// Change the text direction of the input (RTL / LTR)
  final TextDirection? textDirection;

  /// The maximum of lines that can be display in the input
  final int? maxLines;

  /// The minimum of lines that can be display in the input
  final int? minLines;

  /// Should this widget expand itself to fill parent
  final bool expands;

  /// List of action the component can handle
  final List<MarkdownType> actions;

  /// Optionnal controller to manage the input
  final TextEditingController? controller;

  /// Provide some decoration to input
  final InputDecoration inputDecoration;

  /// Constructor for [MarkdownTextInput]
  MarkdownTextInput({
    this.controller,
    this.onChanged,
    this.validators,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.minLines,
    this.expands = false,
    this.actions = const [
      MarkdownType.bold,
      MarkdownType.italic,
      MarkdownType.title,
      MarkdownType.link,
      MarkdownType.list
    ],
    this.inputDecoration =
        const InputDecoration(hintText: 'Type here...', isDense: true),
  });

  @override
  _MarkdownTextInputState createState() => _MarkdownTextInputState();
}

class _MarkdownTextInputState extends State<MarkdownTextInput> {
  late final TextEditingController _controller;

  TextSelection textSelection =
      const TextSelection(baseOffset: 0, extentOffset: 0);

  void onTap(MarkdownType type, {int titleSize = 1}) {
    final basePosition = textSelection.baseOffset;
    var noTextSelected =
        (textSelection.baseOffset - textSelection.extentOffset) == 0;

    final result = FormatMarkdown.convertToMarkdown(type, _controller.text,
        textSelection.baseOffset, textSelection.extentOffset,
        titleSize: titleSize);

    _controller.value = _controller.value.copyWith(
        text: result.data,
        selection:
            TextSelection.collapsed(offset: basePosition + result.cursorIndex));

    if (noTextSelected) {
      _controller.selection = TextSelection.collapsed(
          offset: _controller.selection.end - result.replaceCursorIndex);
    }
  }

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      if (_controller.selection.baseOffset != -1)
        textSelection = _controller.selection;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextFormField(
          textInputAction: TextInputAction.newline,
          maxLines: widget.expands ? null : widget.maxLines,
          minLines: widget.expands ? null : widget.minLines,
          expands: widget.expands,
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          validator: widget.validators,
          decoration: widget.inputDecoration,
          onChanged: widget.onChanged,
        ),
        SizedBox(
          height: 44,
          child: Material(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.actions.map((type) {
                return type == MarkdownType.title
                    ? ExpandableNotifier(
                        child: Expandable(
                          key: Key('H#_button'),
                          collapsed: ExpandableButton(
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'H#',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          expanded: Container(
                            color: Colors.white10,
                            child: Row(
                              children: [
                                for (int i = 1; i <= 6; i++)
                                  InkWell(
                                    key: Key('H${i}_button'),
                                    onTap: () =>
                                        onTap(MarkdownType.title, titleSize: i),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'H$i',
                                        style: TextStyle(
                                            fontSize: (18 - i).toDouble(),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ExpandableButton(
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.close,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : InkWell(
                        key: Key(type.key),
                        onTap: () => onTap(type),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(type.icon),
                        ),
                      );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}
