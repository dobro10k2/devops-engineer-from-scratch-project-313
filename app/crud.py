# app/crud.py
# CRUD operations for the Link model.

from fastapi import HTTPException
from sqlmodel import Session, select

from .models import Link
from .schemas import LinkCreate, LinkUpdate


def create_short_url(base_url: str, short_name: str) -> str:
    """Build short_url from BASE_URL and short_name."""
    return f"{base_url}/r/{short_name}"


def get_all_links(session: Session):
    return session.exec(select(Link)).all()


def get_link(session: Session, link_id: int) -> Link:
    link = session.get(Link, link_id)
    if not link:
        raise HTTPException(status_code=404, detail="Link not found")
    return link


def create_link(session: Session, data: LinkCreate, base_url: str) -> Link:
    # Check duplicate short_name
    existing = session.exec(
        select(Link).where(Link.short_name == data.short_name)
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail="Short name already exists"
        )

    short_url = create_short_url(base_url, data.short_name)

    link = Link(
        original_url=data.original_url,
        short_name=data.short_name,
        short_url=short_url,
    )
    session.add(link)
    session.commit()
    session.refresh(link)
    return link


def update_link(session: Session, link_id: int, data: LinkUpdate, base_url: str) -> Link:
    link = get_link(session, link_id)

    # Check if short_name updated and conflicts with another record
    if data.short_name != link.short_name:
        exists = session.exec(
            select(Link).where(Link.short_name == data.short_name)
        ).first()
        if exists:
            raise HTTPException(
                status_code=400,
                detail="Short name already exists"
            )

    link.original_url = data.original_url
    link.short_name = data.short_name
    link.short_url = create_short_url(base_url, data.short_name)

    session.add(link)
    session.commit()
    session.refresh(link)
    return link


def delete_link(session: Session, link_id: int) -> None:
    link = get_link(session, link_id)
    session.delete(link)
    session.commit()

